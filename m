Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 234736B0003
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 10:32:52 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id z17-v6so999298wrr.16
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 07:32:52 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b11-v6sor8224012wrw.35.2018.08.15.07.32.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Aug 2018 07:32:50 -0700 (PDT)
Date: Wed, 15 Aug 2018 16:32:48 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 0/3] Do not touch pages in remove_memory path
Message-ID: <20180815143248.GA10577@techadventures.net>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <DM5PR21MB0508CEC7F586EBC89D2CCFBB9D3F0@DM5PR21MB0508.namprd21.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <DM5PR21MB0508CEC7F586EBC89D2CCFBB9D3F0@DM5PR21MB0508.namprd21.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <Pavel.Tatashin@microsoft.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "david@redhat.com" <david@redhat.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "logang@deltatee.com" <logang@deltatee.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 15, 2018 at 02:05:35PM +0000, Pavel Tatashin wrote:
> > This tries to fix [1], which was reported by David Hildenbrand, and also
> > does some cleanups/refactoring.
> 
> Hi Oscar,
> 
> I would like to review this work. Are you in process of sending a new version? If so, I will wait for it.

Hi Pavel,

Yes, I plan to send a new version by Friday latest (although I hope tomorrow).

Thanks
-- 
Oscar Salvador
SUSE L3
