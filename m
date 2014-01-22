Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f174.google.com (mail-ve0-f174.google.com [209.85.128.174])
	by kanga.kvack.org (Postfix) with ESMTP id 814CF6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 15:13:28 -0500 (EST)
Received: by mail-ve0-f174.google.com with SMTP id pa12so546434veb.19
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 12:13:28 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTP id x3si5180591vcn.84.2014.01.22.12.13.26
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 12:13:27 -0800 (PST)
From: Chris Mason <clm@fb.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Date: Wed, 22 Jan 2014 20:13:20 +0000
Message-ID: <1390421691.1198.43.camel@ret.masoncoding.com>
References: <20131220093022.GV11295@suse.de> <52DF353D.6050300@redhat.com>
	 <20140122093435.GS4963@suse.de> <52DFD168.8080001@redhat.com>
	 <20140122143452.GW4963@suse.de> <52DFDCA6.1050204@redhat.com>
	 <20140122151913.GY4963@suse.de>
	 <1390410233.1198.7.camel@ret.masoncoding.com>
	 <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
	 <1390413819.1198.20.camel@ret.masoncoding.com>
	 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
	 <52E00B28.3060609@redhat.com>
	 <1390415703.2372.62.camel@dabdike.int.hansenpartnership.com>
	 <52E0106B.5010604@redhat.com>
	 <1390419019.2372.89.camel@dabdike.int.hansenpartnership.com>
	 <20140122115002.bb5d01dee836b567a7aad157@linux-foundation.org>
In-Reply-To: <20140122115002.bb5d01dee836b567a7aad157@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-7"
Content-ID: <4377FC09DDDAD244BD307A4929AD8592@fb.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "James.Bottomley@hansenpartnership.com" <James.Bottomley@hansenpartnership.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, 2014-01-22 at 11:50 -0800, Andrew Morton wrote:
+AD4- On Wed, 22 Jan 2014 11:30:19 -0800 James Bottomley +ADw-James.Bottoml=
ey+AEA-hansenpartnership.com+AD4- wrote:
+AD4-=20
+AD4- +AD4- But this, I think, is the fundamental point for debate.  If we =
can pull
+AD4- +AD4- alignment and other tricks to solve 99+ACU- of the problem is t=
here a need
+AD4- +AD4- for radical VM surgery?  Is there anything coming down the pipe=
 in the
+AD4- +AD4- future that may move the devices ahead of the tricks?
+AD4-=20
+AD4- I expect it would be relatively simple to get large blocksizes workin=
g
+AD4- on powerpc with 64k PAGE+AF8-SIZE.  So before diving in and doing hug=
e
+AD4- amounts of work, perhaps someone can do a proof-of-concept on powerpc
+AD4- (or ia64) with 64k blocksize.


Maybe 5 drives in raid5 on MD, with 4K coming from each drive.  Well
aligned 16K IO will work, everything else will about the same as a rmw
from a single drive.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
