Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 15B6C6B0062
	for <linux-mm@kvack.org>; Fri, 15 May 2009 15:40:03 -0400 (EDT)
Subject: Re: [PATCH 11/11] mm: Convert #ifdef DEBUG printk(KERN_DEBUG to
 pr_debug(
From: Joe Perches <joe@perches.com>
In-Reply-To: <20090515185602.GA28604@us.ibm.com>
References: <cover.1242407227.git.joe@perches.com>
	 <d2d789905b3ec219d015729a162be7707564fb67.1242407227.git.joe@perches.com>
	 <20090515185602.GA28604@us.ibm.com>
Content-Type: text/plain
Date: Fri, 15 May 2009 12:40:25 -0700
Message-Id: <1242416425.3373.50.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, James Morris <jmorris@namei.org>, David Rientjes <rientjes@google.com>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-05-15 at 13:56 -0500, Serge E. Hallyn wrote:
> Seems reasonable - apart from my woes with dynamic_printk :)

pr_devel instead?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
