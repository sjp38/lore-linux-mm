Received: from inergen.sybase.com (inergen.sybase.com [192.138.151.43])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA31654
	for <linux-mm@kvack.org>; Wed, 27 Jan 1999 18:36:01 -0500
Message-ID: <36AFA207.AB6D149E@sybase.com>
Date: Wed, 27 Jan 1999 17:32:23 -0600
From: Jason Froebe <jfroebe@sybase.com>
MIME-Version: 1.0
Subject: Re: Shared memory segment > 1gb
References: <F6D006CF40DA6D8485256706006560F5.006560A786256706@sybase.com>
Content-Type: multipart/mixed;
 boundary="------------03FEC94B406D698DBC8E2130"
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------03FEC94B406D698DBC8E2130
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Jason Froebe wrote:

> Hi,
>
> I'm trying to get a shared memory segment of just under 2 gb.  So
> far, I've been able to get a 893mb shared segment by altering the
> _SHM_IDX_BITS to 18 in include/asm/shmparam.h using the 2.2.0
> kernel.  I'm assuming I can set the _SHM_IDX_BITS to 19 without a
> problem (more overhead though), but since this is my "working"
> computer, I don't want any surprises.  is this possible without
> breaking something?  I glanced at the code but didn't see any
> obvious "gotchas".
>
> Don't ask why I don't use multiple segments.  It's not my
> decision.
>
> Jason
>
>  - jfroebe.vcf

Hi,

I've increased the _SHM_IDX_BITS to 19 and decreased _SHM_ID_BITS to
5 with SHMMAX set to 2gb - 2*page size but it didn't help.  I'm
still stuck at 893mb.

Does anyone know of how to increase the shared memory segment
further without using multiple segments?

Thanks

Jason

--------------03FEC94B406D698DBC8E2130
Content-Type: text/x-vcard; charset=us-ascii;
 name="jfroebe.vcf"
Content-Transfer-Encoding: 7bit
Content-Description: Card for Jason Froebe
Content-Disposition: attachment;
 filename="jfroebe.vcf"

begin:vcard 
n:Froebe;Jason
tel;fax:773-864-7288
tel;work:1-800-8SYBASE
x-mozilla-html:TRUE
url:http://www.sybase.com
org:Sybase, Inc.;Technical Support
adr:;;8755 W. Higgins Road Suite 1000	;Chicago;IL;60631;USA
version:2.1
email;internet:jfroebe@sybase.com
title:Technical Support Engineer
x-mozilla-cpt:;20256
fn:Jason Froebe
end:vcard

--------------03FEC94B406D698DBC8E2130--

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
