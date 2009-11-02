Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 615456B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 23:21:58 -0500 (EST)
Message-ID: <4AEE5EA2.6010905@kernel.org>
Date: Mon, 02 Nov 2009 05:22:58 +0100
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] MM: slqb, fix per_cpu access
References: <1257113578-1584-1-git-send-email-jirislaby@gmail.com>
In-Reply-To: <1257113578-1584-1-git-send-email-jirislaby@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: npiggin@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hello,

Jiri Slaby wrote:
> @@ -2770,16 +2770,16 @@ static DEFINE_PER_CPU(struct delayed_work, cache_trim_work);

How about renaming cache_trim_work to slqb_cache_trim_work?  Another
percpu name requirement is global uniqueness (for s390 and alpha
support), so prefixing perpcu variables with subsystem name usually
resolves situations like this better.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
