Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 915DE62012A
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 04:06:53 -0400 (EDT)
From: "Kleen, Andi" <andi.kleen@intel.com>
Date: Wed, 4 Aug 2010 09:06:18 +0100
Subject: RE: scalability investigation: Where can I get your latest patches?
Message-ID: <F4DF93C7785E2549970341072BC32CD78D8FC0CC@irsmsx503.ger.corp.intel.com>
References: <1278579387.2096.889.camel@ymzhang.sh.intel.com>
	 <20100720031201.GC21274@amd>
	 <1280883843.2125.20.camel@ymzhang.sh.intel.com>
	 <F4DF93C7785E2549970341072BC32CD78D8FC01B@irsmsx503.ger.corp.intel.com>
 <1280908717.2125.33.camel@ymzhang.sh.intel.com>
In-Reply-To: <1280908717.2125.33.camel@ymzhang.sh.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Nick Piggin <npiggin@suse.de>, "Shi, Alex" <alex.shi@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > I believe the latest version of Nick's patchkit has a likely fix for
> that.
> >
> > http://git.kernel.org/?p=3Dlinux/kernel/git/npiggin/linux-
> npiggin.git;a=3Dcommitdiff;h=3D9edd35f9aeafc8a5e1688b84cf4488a94898ca45
>=20
> Thanks Andi. The patch has no ext3 part.

Good point. But perhaps the ext2 patch can be adapted. The ACL code
should be similar in ext2 and ext3 (and 4)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
