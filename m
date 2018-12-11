Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id B522A8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 04:01:01 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id 77so404816wmr.5
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:01:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n12sor9112410wrv.1.2018.12.11.01.01.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 01:01:00 -0800 (PST)
Date: Tue, 11 Dec 2018 10:00:56 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [tip:x86/pti] x86/speculation/l1tf: Drop the swap storage limit
 restriction when l1tf=off
Message-ID: <20181211090056.GA30493@gmail.com>
References: <20181113184910.26697-1-mhocko@kernel.org>
 <tip-f4abaa98c4575cc06ea5e1a593e3bc2c8de8ef48@git.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <tip-f4abaa98c4575cc06ea5e1a593e3bc2c8de8ef48@git.kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mhocko@suse.com, bp@suse.de, pasha.tatashin@soleen.com, tglx@linutronix.de, linux-kernel@vger.kernel.org, dave.hansen@intel.com, torvalds@linux-foundation.org, hpa@zytor.com, jkosina@suse.cz, ak@linux.intel.com
Cc: linux-tip-commits@vger.kernel.org


* tip-bot for Michal Hocko <tipbot@zytor.com> wrote:

> Commit-ID:  f4abaa98c4575cc06ea5e1a593e3bc2c8de8ef48
> Gitweb:     https://git.kernel.org/tip/f4abaa98c4575cc06ea5e1a593e3bc2c8de8ef48
> Author:     Michal Hocko <mhocko@suse.com>
> AuthorDate: Tue, 13 Nov 2018 19:49:10 +0100
> Committer:  Thomas Gleixner <tglx@linutronix.de>
> CommitDate: Mon, 10 Dec 2018 22:07:02 +0100
> 
> x86/speculation/l1tf: Drop the swap storage limit restriction when l1tf=off

> [ tglx: Folded the documentation delta change ]

> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -2095,6 +2095,9 @@
>  			off
>  				Disables hypervisor mitigations and doesn't
>  				emit any warnings.
> +				It also drops the swap size and available
> +				RAM limit restriction on both hypervisor and
> +				bare metal.

>  
>  			Default is 'flush'.
>  
> diff --git a/Documentation/admin-guide/l1tf.rst b/Documentation/admin-guide/l1tf.rst
> index b85dd80510b0..2e65e6cb033e 100644
> --- a/Documentation/admin-guide/l1tf.rst
> +++ b/Documentation/admin-guide/l1tf.rst
> @@ -405,6 +405,9 @@ time with the option "l1tf=". The valid arguments for this option are:
>  
>    off		Disables hypervisor mitigations and doesn't emit any
>  		warnings.
> +		It also drops the swap size and available RAM limit restrictions
> +                on both hypervisor and bare metal.
> +

Note tha there's also some whitespace damage here: all other similar 
lines in this RST file start with two tabs, this one starts with 8 
spaces.

Thanks,

	Ingo
