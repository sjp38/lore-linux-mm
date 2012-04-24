Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 8A7A46B004A
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 13:17:46 -0400 (EDT)
Received: by dadq36 with SMTP id q36so1336215dad.8
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 10:17:45 -0700 (PDT)
Message-ID: <4F96E03F.3080200@gmail.com>
Date: Tue, 24 Apr 2012 13:17:51 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm V2] do_migrate_pages() calls migrate_to_node() even
 if task is already on a correct node
References: <4F96CDE1.5000909@redhat.com> <4F96D27A.2050005@gmail.com> <4F96DFE0.6040306@redhat.com>
In-Reply-To: <4F96DFE0.6040306@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lwoodman@redhat.com
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Motohiro Kosaki <mkosaki@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>kosaki.motohiro@gmail.com

> How does this look:

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
