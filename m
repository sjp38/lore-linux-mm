Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7854B8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 05:48:23 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id t199so506381wmd.3
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 02:48:23 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w8si8664671wrp.196.2018.12.11.02.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 11 Dec 2018 02:48:22 -0800 (PST)
Date: Tue, 11 Dec 2018 11:47:52 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [tip:x86/pti] x86/speculation/l1tf: Drop the swap storage limit
 restriction when l1tf=off
In-Reply-To: <20181211090056.GA30493@gmail.com>
Message-ID: <alpine.DEB.2.21.1812111147300.8611@nanos.tec.linutronix.de>
References: <20181113184910.26697-1-mhocko@kernel.org> <tip-f4abaa98c4575cc06ea5e1a593e3bc2c8de8ef48@git.kernel.org> <20181211090056.GA30493@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-mm@kvack.org, mhocko@suse.com, bp@suse.de, pasha.tatashin@soleen.com, linux-kernel@vger.kernel.org, dave.hansen@intel.com, torvalds@linux-foundation.org, hpa@zytor.com, jkosina@suse.cz, ak@linux.intel.com, linux-tip-commits@vger.kernel.org

On Tue, 11 Dec 2018, Ingo Molnar wrote:
> >    off		Disables hypervisor mitigations and doesn't emit any
> >  		warnings.
> > +		It also drops the swap size and available RAM limit restrictions
> > +                on both hypervisor and bare metal.
> > +
> 
> Note tha there's also some whitespace damage here: all other similar 
> lines in this RST file start with two tabs, this one starts with 8 
> spaces.

Fixed...
