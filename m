Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7661F6B01C1
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 13:09:38 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5EGw8ta023824
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 12:58:08 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5EH9Ytc132294
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 13:09:34 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5EH9XCg022978
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 14:09:33 -0300
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page
 cache control
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100614165853.GW5191@balbir.in.ibm.com>
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
	 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
	 <4C10B3AF.7020908@redhat.com> <20100610142512.GB5191@balbir.in.ibm.com>
	 <1276214852.6437.1427.camel@nimitz>
	 <20100611045600.GE5191@balbir.in.ibm.com> <4C15E3C8.20407@redhat.com>
	 <20100614084810.GT5191@balbir.in.ibm.com>
	 <1276528376.6437.7176.camel@nimitz>
	 <20100614165853.GW5191@balbir.in.ibm.com>
Content-Type: text/plain
Date: Mon, 14 Jun 2010 10:09:31 -0700
Message-Id: <1276535371.6437.7417.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Avi Kivity <avi@redhat.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-14 at 22:28 +0530, Balbir Singh wrote:
> If you've got duplicate pages and you know
> that they are duplicated and can be retrieved at a lower cost, why
> wouldn't we go after them first?

I agree with this in theory.  But, the guest lacks the information about
what is truly duplicated and what the costs are for itself and/or the
host to recreate it.  "Unmapped page cache" may be the best proxy that
we have at the moment for "easy to recreate", but I think it's still too
poor a match to make these patches useful.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
