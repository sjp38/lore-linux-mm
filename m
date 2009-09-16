Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1751F6B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 08:53:58 -0400 (EDT)
Received: by ywh9 with SMTP id 9so6973614ywh.32
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 05:54:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090916160651.88b10377.sfr@canb.auug.org.au>
References: <8bd0f97a0909152056h61bfc487g6b8631966c6d72be@mail.gmail.com>
	<20090915211810.d1b83015.akpm@linux-foundation.org> <8bd0f97a0909152124n186278feja97a7257548b3eb7@mail.gmail.com>
	<20090916160651.88b10377.sfr@canb.auug.org.au>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Wed, 16 Sep 2009 08:53:46 -0400
Message-ID: <8bd0f97a0909160553r4dae0eb7j345dea2a68fa4310@mail.gmail.com>
Subject: Re: 2.6.32 -mm Blackfin patches
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 16, 2009 at 02:06, Stephen Rothwell wrote:
> On Wed, 16 Sep 2009 00:24:37 -0400 Mike Frysinger wrote:
>> not sure how the next process works. =C2=A0what do i need to do Stephen =
?
>
> You send me a request for inclusion with a git tree (and branch) =C2=A0(o=
r
> quilt series on a web site) and contact address(es) and understand the
> following:

ok, please replace the current Blackfin tree:
    git://git.kernel.org/pub/scm/linux/kernel/git/cooloney/blackfin-2.6.git=
#for-linus
with my Blackfin tree:
    git://git.kernel.org/pub/scm/linux/kernel/git/vapier/blackfin.git#for-l=
inus

and i'll try to keep it updated
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
