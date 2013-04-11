From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 05/10] staging: ramster: Move debugfs code out of
 ramster.c file
Date: Fri, 12 Apr 2013 07:27:41 +0800
Message-ID: <37087.0740771808$1365722879@news.gmane.org>
References: <1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1365553560-32258-6-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130411200428.GA31680@kroah.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UQQuI-000066-K3
	for glkm-linux-mm-2@m.gmane.org; Fri, 12 Apr 2013 01:27:54 +0200
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id CDC866B0027
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:27:51 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 12 Apr 2013 04:52:16 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 9F8453940023
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 04:57:43 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3BNRbYj10944820
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 04:57:37 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3BNRgIO014212
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 09:27:43 +1000
Content-Disposition: inline
In-Reply-To: <20130411200428.GA31680@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>

On Thu, Apr 11, 2013 at 01:04:28PM -0700, Greg Kroah-Hartman wrote:
>On Wed, Apr 10, 2013 at 08:25:55AM +0800, Wanpeng Li wrote:
>> Note that at this point there is no CONFIG_RAMSTER_DEBUG
>> option in the Kconfig. So in effect all of the counters
>> are nop until that option gets re-introduced in:
>> zcache/ramster/debug: Add RAMSTE_DEBUG Kconfig entry
>
>This patch breaks the build badly:
>
>drivers/staging/zcache/ramster/ramster.c: In function =E2=80=98ramster_l=
ocalify=E2=80=99:
>drivers/staging/zcache/ramster/ramster.c:159:4: error: =E2=80=98ramster_=
remote_eph_pages_unsucc_get=E2=80=99 undeclared (first use in this functi=
on)
>drivers/staging/zcache/ramster/ramster.c:159:4: note: each undeclared id=
entifier is reported only once for each function it appears in
>drivers/staging/zcache/ramster/ramster.c:161:4: error: =E2=80=98ramster_=
remote_pers_pages_unsucc_get=E2=80=99 undeclared (first use in this funct=
ion)
>drivers/staging/zcache/ramster/ramster.c:212:3: error: =E2=80=98ramster_=
remote_eph_pages_succ_get=E2=80=99 undeclared (first use in this function=
)
>drivers/staging/zcache/ramster/ramster.c:214:3: error: =E2=80=98ramster_=
remote_pers_pages_succ_get=E2=80=99 undeclared (first use in this functio=
n)
>drivers/staging/zcache/ramster/ramster.c: In function =E2=80=98ramster_p=
ampd_repatriate_preload=E2=80=99:
>drivers/staging/zcache/ramster/ramster.c:299:3: error: =E2=80=98ramster_=
pers_pages_remote_nomem=E2=80=99 undeclared (first use in this function)
>drivers/staging/zcache/ramster/ramster.c: In function =E2=80=98ramster_r=
emote_flush_page=E2=80=99:
>drivers/staging/zcache/ramster/ramster.c:437:3: error: =E2=80=98ramster_=
remote_pages_flushed=E2=80=99 undeclared (first use in this function)
>drivers/staging/zcache/ramster/ramster.c:439:3: error: =E2=80=98ramster_=
remote_page_flushes_failed=E2=80=99 undeclared (first use in this functio=
n)
>drivers/staging/zcache/ramster/ramster.c: In function =E2=80=98ramster_r=
emote_flush_object=E2=80=99:
>drivers/staging/zcache/ramster/ramster.c:454:3: error: =E2=80=98ramster_=
remote_objects_flushed=E2=80=99 undeclared (first use in this function)
>drivers/staging/zcache/ramster/ramster.c:456:3: error: =E2=80=98ramster_=
remote_object_flushes_failed=E2=80=99 undeclared (first use in this funct=
ion)
>drivers/staging/zcache/ramster/ramster.c: In function =E2=80=98ramster_r=
emotify_pageframe=E2=80=99:
>drivers/staging/zcache/ramster/ramster.c:507:5: error: =E2=80=98ramster_=
eph_pages_remote_failed=E2=80=99 undeclared (first use in this function)
>drivers/staging/zcache/ramster/ramster.c:509:5: error: =E2=80=98ramster_=
pers_pages_remote_failed=E2=80=99 undeclared (first use in this function)
>drivers/staging/zcache/ramster/ramster.c:516:4: error: =E2=80=98ramster_=
eph_pages_remoted=E2=80=99 undeclared (first use in this function)
>drivers/staging/zcache/ramster/ramster.c:518:4: error: =E2=80=98ramster_=
pers_pages_remoted=E2=80=99 undeclared (first use in this function)
>make[3]: *** [drivers/staging/zcache/ramster/ramster.o] Error 1
>
>Please always test your patches.
>
>I've applied patch 1, 3, and 4 in this series.  Please fix this up if yo=
u want
>me to apply anything else.

Sorry for the bisect issue in my patchset, I will fix it and repost
ASAP. Thanks for your patient.=20

Regards,
Wanpeng Li=20

>
>greg k-h
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
