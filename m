Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 52A306B0037
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 12:02:30 -0500 (EST)
Received: by mail-ie0-f170.google.com with SMTP id u16so10145724iet.15
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 09:02:30 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTP id ri9si1772291igc.25.2014.01.22.09.02.28
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 09:02:29 -0800 (PST)
From: Chris Mason <clm@fb.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Date: Wed, 22 Jan 2014 17:02:22 +0000
Message-ID: <1390410233.1198.7.camel@ret.masoncoding.com>
References: <20131220093022.GV11295@suse.de> <52DF353D.6050300@redhat.com>
	 <20140122093435.GS4963@suse.de> <52DFD168.8080001@redhat.com>
	 <20140122143452.GW4963@suse.de> <52DFDCA6.1050204@redhat.com>
	 <20140122151913.GY4963@suse.de>
In-Reply-To: <20140122151913.GY4963@suse.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-7"
Content-ID: <4E67A8110517DE4EBE4C6EAB2166FDA1@fb.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mgorman@suse.de" <mgorman@suse.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Wed, 2014-01-22 at 15:19 +-0000, Mel Gorman wrote:
+AD4- On Wed, Jan 22, 2014 at 09:58:46AM -0500, Ric Wheeler wrote:
+AD4- +AD4- On 01/22/2014 09:34 AM, Mel Gorman wrote:
+AD4- +AD4- +AD4-On Wed, Jan 22, 2014 at 09:10:48AM -0500, Ric Wheeler wrot=
e:
+AD4- +AD4- +AD4APg-On 01/22/2014 04:34 AM, Mel Gorman wrote:
+AD4- +AD4- +AD4APgA+-On Tue, Jan 21, 2014 at 10:04:29PM -0500, Ric Wheeler=
 wrote:
+AD4- +AD4- +AD4APgA+AD4-One topic that has been lurking forever at the edg=
es is the current
+AD4- +AD4- +AD4APgA+AD4-4k limitation for file system block sizes. Some de=
vices in
+AD4- +AD4- +AD4APgA+AD4-production today and others coming soon have large=
r sectors and it
+AD4- +AD4- +AD4APgA+AD4-would be interesting to see if it is time to poke =
at this topic
+AD4- +AD4- +AD4APgA+AD4-again.
+AD4- +AD4- +AD4APgA+AD4-
+AD4- +AD4- +AD4APgA+-Large block support was proposed years ago by Christo=
ph Lameter
+AD4- +AD4- +AD4APgA+-(http://lwn.net/Articles/232757/). I think I was just=
 getting started
+AD4- +AD4- +AD4APgA+-in the community at the time so I do not recall any o=
f the details. I do
+AD4- +AD4- +AD4APgA+-believe it motivated an alternative by Nick Piggin ca=
lled fsblock though
+AD4- +AD4- +AD4APgA+-(http://lwn.net/Articles/321390/). At the very least =
it would be nice to
+AD4- +AD4- +AD4APgA+-know why neither were never merged for those of us th=
at were not around
+AD4- +AD4- +AD4APgA+-at the time and who may not have the chance to dive t=
hrough mailing list
+AD4- +AD4- +AD4APgA+-archives between now and March.
+AD4- +AD4- +AD4APgA+-
+AD4- +AD4- +AD4APgA+-FWIW, I would expect that a show-stopper for any prop=
osal is requiring
+AD4- +AD4- +AD4APgA+-high-order allocations to succeed for the system to b=
ehave correctly.
+AD4- +AD4- +AD4APgA+-
+AD4- +AD4- +AD4APg-I have a somewhat hazy memory of Andrew warning us that=
 touching
+AD4- +AD4- +AD4APg-this code takes us into dark and scary places.
+AD4- +AD4- +AD4APg-
+AD4- +AD4- +AD4-That is a light summary. As Andrew tends to reject patches=
 with poor
+AD4- +AD4- +AD4-documentation in case we forget the details in 6 months, I=
'm going to guess
+AD4- +AD4- +AD4-that he does not remember the details of a discussion from=
 7ish years ago.
+AD4- +AD4- +AD4-This is where Andrew swoops in with a dazzling display of =
his eidetic
+AD4- +AD4- +AD4-memory just to prove me wrong.
+AD4- +AD4- +AD4-
+AD4- +AD4- +AD4-Ric, are there any storage vendor that is pushing for this=
 right now?
+AD4- +AD4- +AD4-Is someone working on this right now or planning to? If th=
ey are, have they
+AD4- +AD4- +AD4-looked into the history of fsblock (Nick) and large block =
support (Christoph)
+AD4- +AD4- +AD4-to see if they are candidates for forward porting or reimp=
lementation?
+AD4- +AD4- +AD4-I ask because without that person there is a risk that the=
 discussion
+AD4- +AD4- +AD4-will go as follows
+AD4- +AD4- +AD4-
+AD4- +AD4- +AD4-Topic leader: Does anyone have an objection to supporting =
larger block
+AD4- +AD4- +AD4-	sizes than the page size?
+AD4- +AD4- +AD4-Room: Send patches and we'll talk.
+AD4- +AD4- +AD4-
+AD4- +AD4-=20
+AD4- +AD4- I will have to see if I can get a storage vendor to make a publ=
ic
+AD4- +AD4- statement, but there are vendors hoping to see this land in Lin=
ux in
+AD4- +AD4- the next few years.
+AD4-=20
+AD4- What about the second and third questions -- is someone working on th=
is
+AD4- right now or planning to? Have they looked into the history of fsbloc=
k
+AD4- (Nick) and large block support (Christoph) to see if they are candida=
tes
+AD4- for forward porting or reimplementation?

I really think that if we want to make progress on this one, we need
code and someone that owns it.  Nick's work was impressive, but it was
mostly there for getting rid of buffer heads.  If we have a device that
needs it and someone working to enable that device, we'll go forward
much faster.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
