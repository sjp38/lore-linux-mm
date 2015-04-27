Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 43DE66B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:30:16 -0400 (EDT)
Received: by wizk4 with SMTP id k4so106579296wiz.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 09:30:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f6si13477880wiw.110.2015.04.27.09.30.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 09:30:14 -0700 (PDT)
Message-ID: <553E6405.1060007@redhat.com>
Date: Mon, 27 Apr 2015 12:29:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Interacting with coherent memory on external devices
References: <20150424150829.GA3840@gmail.com> <alpine.DEB.2.11.1504241052240.9889@gentwo.org> <20150424164325.GD3840@gmail.com> <alpine.DEB.2.11.1504241148420.10475@gentwo.org> <20150424171957.GE3840@gmail.com> <alpine.DEB.2.11.1504241353280.11285@gentwo.org> <20150424192859.GF3840@gmail.com> <alpine.DEB.2.11.1504241446560.11700@gentwo.org> <20150425114633.GI5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504271004240.28895@gentwo.org> <20150427154728.GA26980@gmail.com> <alpine.DEB.2.11.1504271113480.29515@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1504271113480.29515@gentwo.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Jerome Glisse <j.glisse@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On 04/27/2015 12:17 PM, Christoph Lameter wrote:
> On Mon, 27 Apr 2015, Jerome Glisse wrote:
> 
>>> Improvements to the general code would be preferred instead of
>>> having specialized solutions for a particular hardware alone.  If the
>>> general code can then handle the special coprocessor situation then we
>>> avoid a lot of code development.
>>
>> I think Paul only big change would be the memory ZONE changes. Having a
>> way to add the device memory as struct page while blocking the kernel
>> allocation from using this memory. Beside that i think the autonuma changes
>> he would need would really be specific to his usecase but would still
>> reuse all of the low level logic.
> 
> Well lets avoid that. 

Why would we want to avoid the sane approach that makes this thing
work with the fewest required changes to core code?

Just because your workload is different from the workload they are
trying to enable?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
