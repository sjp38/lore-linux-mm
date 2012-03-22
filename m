Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 52B2E6B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 16:14:08 -0400 (EDT)
Message-ID: <4F6B880C.7000805@redhat.com>
Date: Thu, 22 Mar 2012 16:14:04 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
References: <4F6B6BFF.1020701@redhat.com> <4F6B7358.60800@gmail.com> <alpine.DEB.2.00.1203221348470.25011@router.home>            <4F6B7854.1040203@redhat.com> <40300.1332445016@turing-police.cc.vt.edu>
In-Reply-To: <40300.1332445016@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Motohiro Kosaki <mkosaki@redhat.com>

On 03/22/2012 03:36 PM, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 22 Mar 2012 15:07:00 -0400, Larry Woodman said:
>
>> So to be clear on this, in that case the intention would be move 3 to 4,
>> 4 to 5 and 5 to 6
>> to keep the node ordering the same?
> Would it make more sense to do 5->6, 4->5, 3->4?  If we move stuff
> from 3 to 4 before clearing the old 4 stuff out, it might get crowded?
>
Yes, I didnt try to imply the order in which pages were moved just
the additional moving necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
