Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id A2A7E6B0031
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 06:26:39 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id hw13so3632944qab.17
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 03:26:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id b6si1666823qae.168.2014.04.10.03.26.38
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 03:26:38 -0700 (PDT)
Message-ID: <534671DB.50802@redhat.com>
Date: Thu, 10 Apr 2014 11:26:35 +0100
From: Jeremy Harris <jgh@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] Disable zone_reclaim_mode by default
References: <1396910068-11637-1-git-send-email-mgorman@suse.de> <5343A494.9070707@suse.cz> <alpine.DEB.2.10.1404080914280.8782@nuc> <CA+TgmoY=vUdtdnJUEK1h-UcaNoqqLUctt44S8vj2B7EVUXUOyA@mail.gmail.com> <alpine.DEB.2.10.1404081752390.16708@nuc>
In-Reply-To: <alpine.DEB.2.10.1404081752390.16708@nuc>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/04/14 23:58, Christoph Lameter wrote:
> The reason that zone reclaim is on by default is that off node accesses
> are a big performance hit on large scale NUMA systems (like ScaleMP and
> SGI). Zone reclaim was written *because* those system experienced severe
> performance degradation.
>
> On the tightly coupled 4 and 8 node systems there does not seem to
> be a benefit from what I hear.

In principle, is this difference in distance something the kernel
could measure?
-- 
Cheers,
    Jeremy


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
