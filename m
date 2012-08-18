Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 4E4806B0069
	for <linux-mm@kvack.org>; Sat, 18 Aug 2012 15:10:42 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <875d22f4-47f4-4dc0-81b7-0a9da59b202d@default>
Date: Sat, 18 Aug 2012 12:10:08 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/3] staging: zcache+ramster: move to new code base and
 re-merge
References: <1345156293-18852-1-git-send-email-dan.magenheimer@oracle.com>
 <20120816224814.GA18737@kroah.com>
 <9f2da295-4164-4e95-bbe8-bd234307b83c@default>
 <20120816230817.GA14757@kroah.com> <502EC67F.4070603@linux.vnet.ibm.com>
In-Reply-To: <502EC67F.4070603@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg KH <gregkh@linuxfoundation.org>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, minchan@kernel.org

[Seth re new redesigned codebase]

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Sent: Friday, August 17, 2012 4:33 PM
>
> So I can't support this patchset, citing the performance
> degradation and the fact that this submission is
> unreviewable due to it being one huge monolithic patchset on
> top of an existing codebase.

[Dan re old demo codebase]

> From: Dan Magenheimer
> Sent: Wednesday, August 08, 2012 11:48 AM
> Subject: RE: [PATCH 0/4] promote zcache from staging
>=20
> Sorry, but FWIW my vote is still a NACK.  IMHO zcache needs major
> work before it should be promoted, and I think we should be spending
> the time fixing the known flaws rather than arguing about promoting
> "demo" code.

:-#

"Well, pahdner," drawls the Colorado cowboy (Dan) to the Texas
cowboy (Seth), "I reckon we gots us a good old fashioned standoff."

"What say we settle this like men, say six-shooters at
twenty paces?"

:-)

Seriously, maybe we should consider a fork?  Zcache and zcache2?

(I am REALLY away from email for a few days starting NOW.)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
