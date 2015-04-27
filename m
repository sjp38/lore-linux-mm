Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f41.google.com (mail-vn0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5D96B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:35:29 -0400 (EDT)
Received: by vnbg1 with SMTP id g1so13357647vnb.2
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:35:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id az11si31301849vdd.56.2015.04.27.12.35.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 12:35:27 -0700 (PDT)
Message-ID: <553E8F75.5060502@redhat.com>
Date: Mon, 27 Apr 2015 15:35:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Interacting with coherent memory on external devices
References: <20150424171957.GE3840@gmail.com> <alpine.DEB.2.11.1504241353280.11285@gentwo.org> <20150424192859.GF3840@gmail.com> <alpine.DEB.2.11.1504241446560.11700@gentwo.org> <20150425114633.GI5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504271004240.28895@gentwo.org> <20150427154728.GA26980@gmail.com> <alpine.DEB.2.11.1504271113480.29515@gentwo.org> <20150427164325.GB26980@gmail.com> <alpine.DEB.2.11.1504271148240.29735@gentwo.org> <20150427172143.GC26980@gmail.com> <alpine.DEB.2.11.1504271411060.30615@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1504271411060.30615@gentwo.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Jerome Glisse <j.glisse@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On 04/27/2015 03:26 PM, Christoph Lameter wrote:

> DAX is about directly accessing memory. It is made for the purpose of
> serving as a block device for a filesystem right now but it can easily be
> used as a way to map any external memory into a processes space using the
> abstraction of a block device. But then you can do that with any device
> driver using VM_PFNMAP or VM_MIXEDMAP. Maybe we better use that term
> instead. Guess I have repeated myself 6 times or so now? I am stopping
> with this one.

Yeah, please stop.

If after 6 times you have still not grasped that having the
application manage which memory goes onto the device and
which goes in RAM is the exact opposite of the use model
that Paul and Jerome are trying to enable (transparent moving
around of memory, by eg. GPU calculation libraries), you are
clearly not paying enough attention.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
