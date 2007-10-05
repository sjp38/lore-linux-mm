Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id l952RF1K020518
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 19:27:15 -0700
Received: from nz-out-0506.google.com (nzii28.prod.google.com [10.36.35.28])
	by zps37.corp.google.com with ESMTP id l952QLFJ002996
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 19:27:15 -0700
Received: by nz-out-0506.google.com with SMTP id i28so364048nzi
        for <linux-mm@kvack.org>; Thu, 04 Oct 2007 19:27:14 -0700 (PDT)
Message-ID: <b040c32a0710041927o3c58f55eica57ce33e979105b@mail.gmail.com>
Date: Thu, 4 Oct 2007 19:27:14 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH][2.6.23-rc8-mm2] Fixes to hugetlbfs_read() support
In-Reply-To: <1191535001.6106.104.camel@dyn9047017100.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071001133524.0566b556.akpm@linux-foundation.org>
	 <1191346335.6106.23.camel@dyn9047017100.beaverton.ibm.com>
	 <20071002111949.c8184a3a.akpm@linux-foundation.org>
	 <1191364926.6106.57.camel@dyn9047017100.beaverton.ibm.com>
	 <b040c32a0710021914i5ced503aoebe6e749cd2201af@mail.gmail.com>
	 <b040c32a0710021941q583e2169t40e196675318f19d@mail.gmail.com>
	 <20071003025853.GA14698@localhost.localdomain>
	 <1191425944.6106.79.camel@dyn9047017100.beaverton.ibm.com>
	 <b040c32a0710031441v3139bd28lce757b2c63796686@mail.gmail.com>
	 <1191535001.6106.104.camel@dyn9047017100.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: David Gibson <david@gibson.dropbear.id.au>, Andrew Morton <akpm@linux-foundation.org>, William Lee Irwin III <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 10/4/07, Badari Pulavarty <pbadari@us.ibm.com> wrote:
> Hi Ken,
>
> Here is the latest against 2.6.23-rc8-mm2. If you are happy with this,
> I will ask Andrew to pick it up. I did test this version :)

Looks good.  I also tested and verified that it works.

Acked-by: Ken Chen <kenchen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
