Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id D722A6B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 03:21:13 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so191272bkw.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 00:21:12 -0700 (PDT)
Message-ID: <4F5EF563.5000700@openvz.org>
Date: Tue, 13 Mar 2012 11:21:07 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: Fwd: Control page reclaim granularity
References: <20120313024818.GA7125@barrios> <1331620214-4893-1-git-send-email-wenqing.lz@taobao.com> <20120313064832.GA4968@gmail.com>
In-Reply-To: <20120313064832.GA4968@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, Zheng Liu <wenqing.lz@taobao.com>

Zheng Liu wrote:
> Sorry, please forgive me.  This patch has a defect.  When one page is
> scaned and flag is clear, all other's flags also are clear too.

Yeah, funny patch =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
