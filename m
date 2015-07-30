Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 02ECF9003C7
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 12:41:42 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so38560365ykd.2
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 09:41:41 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id h125si1237272ywd.91.2015.07.30.09.41.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 09:41:40 -0700 (PDT)
Message-ID: <55BA53AF.8050406@citrix.com>
Date: Thu, 30 Jul 2015 17:41:19 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCHv1] mm: always initialize pages as reserved to fix memory
 hotplug
References: <1438265083-31208-1-git-send-email-david.vrabel@citrix.com>
 <20150730144554.GS2561@suse.de>
In-Reply-To: <20150730144554.GS2561@suse.de>
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>

On 30/07/15 15:45, Mel Gorman wrote:
> On Thu, Jul 30, 2015 at 03:04:43PM +0100, David Vrabel wrote:
>> Commit 92923ca3aacef63c92dc297a75ad0c6dfe4eab37 (mm: meminit: only set
>> page reserved in the memblock region) breaks memory hotplug because pages
>> within newly added sections are not marked as reserved as required by
>> the memory hotplug driver.
> 
> I don't have access to a large machine at the moment to verify and won't
> have until Monday at the earliest but I think that will bust deferred
> initialisation.
> 
> Why not either SetPageReserved from mem hotplug driver? It might be neater
> to remove the PageReserved check from online_pages_range() but then care
> would have to be taken to ensure that invalid PFNs within section that
> have no memory backing them were properly reserved.  This is an untested,
> uncompiled version of the first suggestion

Thanks.

Tested-by: David Vrabel <david.vrabel@citrix.com>

8<------------------------------
