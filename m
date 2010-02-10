Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 628E26B0095
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 16:34:43 -0500 (EST)
From: Lubos Lunak <l.lunak@suse.cz>
Subject: Re: Improving OOM killer
Date: Wed, 10 Feb 2010 22:34:38 +0100
References: <201002012302.37380.l.lunak@suse.cz> <201002102154.39771.l.lunak@suse.cz> <4B73206C.8090108@redhat.com>
In-Reply-To: <4B73206C.8090108@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002102234.38377.l.lunak@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wednesday 10 of February 2010, Rik van Riel wrote:
> On 02/10/2010 03:54 PM, Lubos Lunak wrote:
> >   Simply computing the cost of the whole children subtree (or a
> > reasonable approximation) avoids the need for any magic numbers and gives
> > a much better representation of how costly the subtree is, since, well,
> > it is the cost itself.
>
> That assumes you want to kill off that entire tree.

 As said in another mail, I think I actually do, since the entire tree is 
indentified as the problem. But regardless of that, surely computing the cost 
of a forkbomb by computing something that is close to the actual cost of it 
is better than trying magic numbers?

-- 
 Lubos Lunak
 openSUSE Boosters team, KDE developer
 l.lunak@suse.cz , l.lunak@kde.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
