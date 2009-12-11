Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C6FEE6B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 10:52:53 -0500 (EST)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBBFpYhL005892
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:51:34 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBBFqQvp032256
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:52:28 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBBFsFo8014487
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:54:16 -0700
Subject: Re: [PATCHv9 3/3] vhost_net: a kernel-level virtio server
From: Shirley Ma <mashirle@us.ibm.com>
In-Reply-To: <20091122103511.GB13644@redhat.com>
References: <cover.1257786516.git.mst@redhat.com>
	 <20091109172230.GD4724@redhat.com>
	 <C85CEDA13AB1CF4D9D597824A86D2B901925446AB4@PDSMSX501.ccr.corp.intel.com>
	 <20091122103511.GB13644@redhat.com>
Content-Type: text/plain
Date: Fri, 11 Dec 2009 07:52:22 -0800
Message-Id: <1260546742.3960.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Xin, Xiaohui" <xiaohui.xin@intel.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@elte.hu" <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "gregory.haskins@gmail.com" <gregory.haskins@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, "s.hetze@linux-ag.com" <s.hetze@linux-ag.com>, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>


On Sun, 2009-11-22 at 12:35 +0200, Michael S. Tsirkin wrote:
> These results where sent by Shirley Ma (Cc'd).
> I think they were with tap, host-to-guest/guest-to-host

Yes, you are right.

Shirley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
