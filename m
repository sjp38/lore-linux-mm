Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1ACC88E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:13:21 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d41so6635658eda.12
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 03:13:21 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n19-v6si647141ejz.135.2018.12.11.03.13.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 03:13:19 -0800 (PST)
Date: Tue, 11 Dec 2018 12:13:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [tip:x86/pti] x86/speculation/l1tf: Drop the swap storage limit
 restriction when l1tf=off
Message-ID: <20181211111318.GH1286@dhcp22.suse.cz>
References: <20181113184910.26697-1-mhocko@kernel.org>
 <tip-f4abaa98c4575cc06ea5e1a593e3bc2c8de8ef48@git.kernel.org>
 <20181211090056.GA30493@gmail.com>
 <alpine.DEB.2.21.1812111147300.8611@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1812111147300.8611@nanos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, bp@suse.de, pasha.tatashin@soleen.com, linux-kernel@vger.kernel.org, dave.hansen@intel.com, torvalds@linux-foundation.org, hpa@zytor.com, jkosina@suse.cz, ak@linux.intel.com, linux-tip-commits@vger.kernel.org

On Tue 11-12-18 11:47:52, Thomas Gleixner wrote:
> On Tue, 11 Dec 2018, Ingo Molnar wrote:
> > >    off		Disables hypervisor mitigations and doesn't emit any
> > >  		warnings.
> > > +		It also drops the swap size and available RAM limit restrictions
> > > +                on both hypervisor and bare metal.
> > > +
> > 
> > Note tha there's also some whitespace damage here: all other similar 
> > lines in this RST file start with two tabs, this one starts with 8 
> > spaces.
> 
> Fixed...

Thanks Thomas! I haven't noticed a different whitespaces and relied on
whatever vim decided to do.

-- 
Michal Hocko
SUSE Labs
