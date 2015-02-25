Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7206B6B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 19:21:19 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so640142pdb.2
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:21:19 -0800 (PST)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id bu6si2616340pad.46.2015.02.24.16.21.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 16:21:18 -0800 (PST)
Message-ID: <1424823644.17007.96.camel@misato.fc.hp.com>
Subject: Re: [PATCH v7 0/7] Support Write-Through mapping on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 24 Feb 2015 17:20:44 -0700
In-Reply-To: <1421963430.2493.26.camel@misato.fc.hp.com>
References: <1420577392-21235-1-git-send-email-toshi.kani@hp.com>
	 <1421342920.2493.8.camel@misato.fc.hp.com>
	 <alpine.DEB.2.11.1501222225000.5526@nanos>
	 <1421963430.2493.26.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com

On Thu, 2015-01-22 at 14:50 -0700, Toshi Kani wrote:
> On Thu, 2015-01-22 at 22:25 +0100, Thomas Gleixner wrote:
> > On Thu, 15 Jan 2015, Toshi Kani wrote:
> > 
> > > Hi Ingo, Peter, Thomas,
> > > 
> > > Is there anything else I need to do for accepting this patchset? 
> > 
> > You might hand me some spare time for reviewing it :)
> > 
> > It's on my list.
> 
> That's great!

Hi Thomas,

I just posted v8 patchset that is rebased to 4.0-rc1.  When you have
chance, please review this new version.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
