Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABD8A6B0273
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 12:34:52 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id a26-v6so8693349qtb.22
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 09:34:52 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id h17-v6si2046850qtr.381.2018.10.04.09.34.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 09:34:51 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 3/3] mm/vmstat: assert that vmstat_text is in sync with
 stat_items_size
Date: Thu, 4 Oct 2018 16:34:26 +0000
Message-ID: <20181004163420.GA24171@tower.DHCP.thefacebook.com>
References: <20181001143138.95119-1-jannh@google.com>
 <20181001143138.95119-3-jannh@google.com>
In-Reply-To: <20181001143138.95119-3-jannh@google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3C41F001299CA040B2494D0C3169290D@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Kemi Wang <kemi.wang@intel.com>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>

On Mon, Oct 01, 2018 at 04:31:38PM +0200, Jann Horn wrote:
> As evidenced by the previous two patches, having two gigantic arrays that
> must manually be kept in sync, including ifdefs, isn't exactly robust.
> To make it easier to catch such issues in the future, add a BUILD_BUG_ON(=
).
>=20
> Signed-off-by: Jann Horn <jannh@google.com>
> ---
>  mm/vmstat.c | 2 ++
>  1 file changed, 2 insertions(+)

I agree with Michal here, we had to do this long time ago.

For patches 1-3:
Acked-by: Roman Gushchin <guro@fb.com>

BTW, don't we want to split this huge array into smaller parts?
This will make the code more clear and easier to modify.

Thank you!
