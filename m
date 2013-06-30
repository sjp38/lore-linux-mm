Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 85D2B6B0032
	for <linux-mm@kvack.org>; Sun, 30 Jun 2013 19:55:57 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B499E3EE0BD
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 08:55:55 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A21D345DE5B
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 08:55:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8612645DE58
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 08:55:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 774551DB804D
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 08:55:55 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 256401DB8046
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 08:55:55 +0900 (JST)
Message-ID: <51D0C500.4060108@jp.fujitsu.com>
Date: Mon, 01 Jul 2013 08:53:36 +0900
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 9/9] vmcore: support mmap() on /proc/vmcore
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6> <20130523052547.13864.83306.stgit@localhost6.localdomain6> <20130523152445.17549682ae45b5aab3f3cde0@linux-foundation.org> <CAJGZr0LwivLTH+E7WAR1B9_6B4e=jv04KgCUL_PdVpi9JjDpBw@mail.gmail.com> <51A2BBA7.50607@jp.fujitsu.com> <CAJGZr0LmsFXEgb3UXVb+rqo1aq5KJyNxyNAD+DG+3KnJm_ZncQ@mail.gmail.com> <51A71B49.3070003@cn.fujitsu.com> <CAJGZr0Ld6Q4a4f-VObAbvqCp=+fTFNEc6M-Fdnhh28GTcSm1=w@mail.gmail.com> <20130603174351.d04b2ac71d1bab0df242e0ba@mxc.nes.nec.co.jp> <CAJGZr0+9VUweN1Ssdq6P9Lug1GnTB3+RPv77JLRmnw=rpd9+Dw@mail.gmail.com>
In-Reply-To: <CAJGZr0+9VUweN1Ssdq6P9Lug1GnTB3+RPv77JLRmnw=rpd9+Dw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Uvarov <muvarov@gmail.com>
Cc: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, riel@redhat.com, kexec@lists.infradead.org, hughd@google.com, linux-kernel@vger.kernel.org, lisa.mitchell@hp.com, vgoyal@redhat.com, linux-mm@kvack.org, zhangyanfei@cn.fujitsu.com, ebiederm@xmission.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, walken@google.com, cpw@sgi.com, jingbai.ma@hp.com

(2013/06/29 1:40), Maxim Uvarov wrote:
> Did test on 1TB machine. Total vmcore capture and save took 143 minutes while vmcore size increased from 9Gb to 59Gb.
>
> Will do some debug for that.
>
> Maxim.

Please show me your kdump configuration file and tell me what you did in the test and how you confirmed the result.

-- 
Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
