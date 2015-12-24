Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id C819B82F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 12:09:22 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id 18so188735514obc.2
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 09:09:22 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id d14si34549812oic.111.2015.12.24.09.09.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Dec 2015 09:09:22 -0800 (PST)
Message-ID: <1450976937.19330.11.camel@hpe.com>
Subject: Re: [PATCH 01/11] resource: Add System RAM resource type
From: Toshi Kani <toshi.kani@hpe.com>
Date: Thu, 24 Dec 2015 10:08:57 -0700
In-Reply-To: <1450923815.19330.4.camel@hpe.com>
References: <20151216122642.GE29775@pd.tnic>
	 <1450280642.29051.76.camel@hpe.com> <20151216154916.GF29775@pd.tnic>
	 <1450283759.20148.11.camel@hpe.com> <20151216174523.GH29775@pd.tnic>
	 <CAPcyv4h+n51Z2hskP2+PX44OB47OQwrKcqVr3nrvMzG++qjC+w@mail.gmail.com>
	 <20151216181712.GJ29775@pd.tnic> <1450302758.20148.75.camel@hpe.com>
	 <20151222113422.GE3728@pd.tnic> <1450814672.10450.83.camel@hpe.com>
	 <20151223142349.GG30213@pd.tnic> <1450923815.19330.4.camel@hpe.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>

On Wed, 2015-12-23 at 19:23 -0700, Toshi Kani wrote:
> On Wed, 2015-12-23 at 15:23 +0100, Borislav Petkov wrote:
> > On Tue, Dec 22, 2015 at 01:04:32PM -0700, Toshi Kani wrote:
>  :
> > > I agree that we can add new interfaces with the type check.  This
> > > 'type'
> > > may need some clarification since it is an assigned type, which is
> > > different from I/O resource type.  That is, "System RAM" is an I/O 
> > > resource type (i.e. IORESOURCE_SYSTEM_RAM), but "Crash kernel" is an 
> > > assigned type to a particular range of System RAM.  A range may be 
> > > associated with multiple names, so as multiple assigned types.  For 
> > > lack of a better idea, I may call it 'assign_type'.  I am open for a
> > > better name.
> > 
> > Or assigned_type or named_type or so...
> > 
> > I think we should avoid calling it "type" completely in order to avoid
> > confusion with the IORESOURCE_* types and call it "desc" or so to mean
> > description, sort, etc, because the name is also a description of the
> > resource to a certain degree...
> 
> Agreed. I will use 'desc'.
> 
> > > OK, I will try to convert the existing callers with the new
> > > interfaces.
> > 
> > Either that or add the new interfaces, use them in your use case, add
> > big fat comments explaining that people should use those from now on
> > when searching by name and add a check to checkpatch to catch future
> > mis-uses...
> 
> Sounds good.  I will look into it.

As for checkpatch, I noticed that commit 9c0ece069b3 removed "feature
-removal.txt" file, and checkpatch removed this check in commit
78e3f1f01d2.  checkpatch does not have such check since then.  So, I am
inclined not to add this check back to checkpatch.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
