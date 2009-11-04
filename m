Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 62A976B006A
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 08:00:06 -0500 (EST)
Date: Wed, 4 Nov 2009 13:59:57 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCHv7 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20091104125957.GL31511@one.firstfloor.org>
References: <cover.1257267892.git.mst@redhat.com> <20091103172422.GD5591@redhat.com> <878wema6o0.fsf@basil.nowhere.org> <20091104121009.GF8398@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091104121009.GF8398@redhat.com>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> Fine?

I cannot say -- are there paths that could drop the device beforehand?
(as in do you hold a reference to it?)

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
