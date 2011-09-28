Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E4D609000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 04:01:36 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p8S81YDb016094
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 01:01:34 -0700
Received: from qyk33 (qyk33.prod.google.com [10.241.83.161])
	by hpaq1.eem.corp.google.com with ESMTP id p8S81TZ9002394
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 01:01:32 -0700
Received: by qyk33 with SMTP id 33so8121724qyk.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2011 01:01:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1317195706.5781.1.camel@twins>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-5-git-send-email-walken@google.com>
	<1317195706.5781.1.camel@twins>
Date: Wed, 28 Sep 2011 01:01:29 -0700
Message-ID: <CANN689Gtv2B1j6Z5wTk1ysne+XVV8VfU+9jepY1RV4r=B7V_Zw@mail.gmail.com>
Subject: Re: [PATCH 4/9] kstaled: minimalistic implementation.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Wed, Sep 28, 2011 at 12:41 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> w=
rote:
> On Tue, 2011-09-27 at 17:49 -0700, Michel Lespinasse wrote:
>> +static int kstaled(void *dummy)
>> +{
>> + =A0 =A0 =A0 while (1) {
>
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 BUG();
>> + =A0 =A0 =A0 return 0; =A0 =A0 =A0 /* NOT REACHED */
>> +}
>
> So if you build with this junk (as I presume distro's will), there is no
> way to disable it?

There will be a thread, and it'll block in wait_event_interruptible()
until a positive value is written into
/sys/kernel/mm/kstaled/scan_seconds

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
