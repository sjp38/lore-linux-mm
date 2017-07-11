Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DAE96B04D1
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 20:54:13 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 16so34964271qkg.15
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 17:54:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a27si6347784qka.139.2017.07.10.17.54.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 17:54:12 -0700 (PDT)
Date: Mon, 10 Jul 2017 20:54:09 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
Message-ID: <20170711005408.GA15896@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <f04a007d-fc34-fe3a-d366-1363248a609f@nvidia.com>
 <20170710234339.GA15226@redhat.com>
 <57146eb3-43bc-6e8b-4c8e-0632aa8ed577@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <57146eb3-43bc-6e8b-4c8e-0632aa8ed577@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Mon, Jul 10, 2017 at 05:17:23PM -0700, Evgeny Baskakov wrote:
> On 7/10/17 4:43 PM, Jerome Glisse wrote:
> 
> > On Mon, Jul 10, 2017 at 03:59:37PM -0700, Evgeny Baskakov wrote:
> > ...
> > Horrible stupid bug in the code, most likely from cut and paste. Attached
> > patch should fix it. I don't know how long it took for you to trigger it.
> > 
> > Jerome
> Thanks, this indeed fixes the problem! Yes, it took a nightly run before it
> triggered.
> 
> One a side note, should this "return NULL" be replaced with "return
> ERR_PTR(-ENOMEM)"?

Or -EBUSY but yes sure.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
