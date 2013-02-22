Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 1E12C6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 08:42:07 -0500 (EST)
Message-ID: <512775CA.2030603@parallels.com>
Date: Fri, 22 Feb 2013 17:42:34 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: slab: Verify the nodeid passed to ____cache_alloc_node
References: <943811281.6485888.1361484478519.JavaMail.root@redhat.com>
In-Reply-To: <943811281.6485888.1361484478519.JavaMail.root@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Tomlin <atomlin@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik <riel@redhat.com>

On 02/22/2013 02:07 AM, Aaron Tomlin wrote:
> The addition of this BUG_ON should make debugging easier.
> While I understand that this code path is "hot", surely
> it is better to assert the condition than to wait until
> some random NULL pointer dereference or page fault. If the
> caller passes an invalid nodeid, at this stage in my opinion
> it's already a BUG.
If you assert with VM_BUG_ON, it will be active on debugging kernels
only, which I believe is better suited for a hotpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
