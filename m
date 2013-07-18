Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 6E68D6B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 09:46:23 -0400 (EDT)
Date: Thu, 18 Jul 2013 13:46:22 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Remove unnecessary page NULL check
In-Reply-To: <1374133191-19012-1-git-send-email-huawei.libin@huawei.com>
Message-ID: <0000013ff2080e94-d489fc54-d262-4314-8591-3187a3f6e829-000000@email.amazonses.com>
References: <1374133191-19012-1-git-send-email-huawei.libin@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Libin <huawei.libin@huawei.com>
Cc: linux-mm@kvack.org, penberg@kernel.org, akpm@linux-foundation.org, mpm@selenic.com, rostedt@goodmis.org, guohanjun@huawei.com, wujianguo@huawei.com

On Thu, 18 Jul 2013, Libin wrote:

> In commit 4d7868e6(slub: Do not dereference NULL pointer in node_match)
> had added check for page NULL in node_match.  Thus, it is not needed
> to check it before node_match, remove it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
