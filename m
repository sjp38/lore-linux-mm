Date: Thu, 7 Dec 2006 17:46:27 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: new procfs memory analysis feature
Message-Id: <20061207174627.63300ccf.akpm@osdl.org>
In-Reply-To: <04710480e9f151439cacdf3dd9d507d1@mvista.com>
References: <45789124.1070207@mvista.com>
	<20061207143611.7a2925e2.akpm@osdl.org>
	<04710480e9f151439cacdf3dd9d507d1@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david singleton <dsingleton@mvista.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Dec 2006 17:07:22 -0800
david singleton <dsingleton@mvista.com> wrote:

> Attached is the 2.6.19 patch.

It still has the overflow bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
