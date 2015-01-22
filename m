Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 95CB26B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 17:06:48 -0500 (EST)
Received: by mail-oi0-f43.google.com with SMTP id z81so3723555oif.2
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 14:06:48 -0800 (PST)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id eo8si11640991oeb.9.2015.01.22.14.06.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 14:06:47 -0800 (PST)
Message-ID: <1421963430.2493.26.camel@misato.fc.hp.com>
Subject: Re: [PATCH v7 0/7] Support Write-Through mapping on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 22 Jan 2015 14:50:30 -0700
In-Reply-To: <alpine.DEB.2.11.1501222225000.5526@nanos>
References: <1420577392-21235-1-git-send-email-toshi.kani@hp.com>
	 <1421342920.2493.8.camel@misato.fc.hp.com>
	 <alpine.DEB.2.11.1501222225000.5526@nanos>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com

On Thu, 2015-01-22 at 22:25 +0100, Thomas Gleixner wrote:
> On Thu, 15 Jan 2015, Toshi Kani wrote:
> 
> > Hi Ingo, Peter, Thomas,
> > 
> > Is there anything else I need to do for accepting this patchset? 
> 
> You might hand me some spare time for reviewing it :)
> 
> It's on my list.

That's great!

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
