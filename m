Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id BBB176B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 14:19:41 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id i4so5036621oah.24
        for <linux-mm@kvack.org>; Thu, 25 Jul 2013 11:19:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B62F8F5C3@SC-VEXCH4.marvell.com>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
 <000001400d38469d-a121fb96-4483-483a-9d3e-fc552e413892-000000@email.amazonses.com>
 <89813612683626448B837EE5A0B6A7CB3B62F8F5C3@SC-VEXCH4.marvell.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 25 Jul 2013 14:19:20 -0400
Message-ID: <CAHGf_=q8JZQ42R-3yzie7DXUEq8kU+TZXgcX9s=dn8nVigXv8g@mail.gmail.com>
Subject: Re: Possible deadloop in direct reclaim?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>

On Tue, Jul 23, 2013 at 9:21 PM, Lisa Du <cldu@marvell.com> wrote:
> Dear Christoph
>    Thanks a lot for your comment. When this issue happen I just trigger a kernel panic and got the kdump.
> From the kdump, I got the global variable pg_data_t congit_page_data. From this structure, I can see in normal zone, only order-0's nr_free = 18442, order-1's nr_free = 367, all the other order's nr_free is 0.

Don't you use compaction? Of if use, please get a log by tracepoints.
We need to know why it doesn't work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
