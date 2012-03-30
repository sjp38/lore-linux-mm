Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 56BF56B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 13:30:48 -0400 (EDT)
Message-ID: <4F75EDC3.7050104@redhat.com>
Date: Fri, 30 Mar 2012 13:30:43 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
References: <4F6B6BFF.1020701@redhat.com> <4F6B7358.60800@gmail.com> <alpine.DEB.2.00.1203221348470.25011@router.home> <4F6B7854.1040203@redhat.com> <alpine.DEB.2.00.1203221421570.25011@router.home> <4F74A344.7070805@redhat.com> <4F74BB67.30703@gmail.com> <alpine.DEB.2.00.1203301113530.22502@router.home>
In-Reply-To: <alpine.DEB.2.00.1203301113530.22502@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Motohiro Kosaki <mkosaki@redhat.com>

On 03/30/2012 12:15 PM, Christoph Lameter wrote:
> On Thu, 29 Mar 2012, KOSAKI Motohiro wrote:
>
>>> 		for_each_node_mask(s, tmp) {
>>> +
>>> +			/* IFF there is an equal number of source and
>>> +			 * destination nodes, maintain relative node distance
>>> +			 * even when source and destination nodes overlap.
>>> +			 * However, when the node weight is unequal, never
>>> move
>>> +			 * memory out of any destination nodes */
>>> +			if ((nodes_weight(*from_nodes) !=
>>> nodes_weight(*to_nodes))&&
>>> +						(node_isset(s, *to_nodes)))
>>> +				continue;
>>> +
>>> 			d = node_remap(s, *from_nodes, *to_nodes);
>>> 			if (s == d)
>>> 				continue;
>> I'm confused. Could you please explain why you choose nodes_weight()? On my
>> first impression,
>> it seems almostly unrelated factor.
> Isnt this the original code by Paul?
No, I added the test to see if the source and destination has the same 
number of nodes.
>   I would think that the 1-1 movement
> is only useful to do if the number of nodes in both the destination and
> the source is the same.
Agreed, thats exactly what this patch does.  are you OK with this change 
then???

Larry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
