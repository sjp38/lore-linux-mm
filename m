Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2976B0253
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 07:42:18 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 189so11621916iow.8
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 04:42:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l129sor3435548ioe.160.2017.10.27.04.42.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Oct 2017 04:42:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171027064854.GE3666@dastard>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171020074750.GA13568@lst.de> <20171020093148.GA20304@lst.de>
 <20171026105850.GA31161@quack2.suse.cz> <1509061831.25213.2.camel@intel.com> <20171027064854.GE3666@dastard>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 27 Oct 2017 13:42:16 +0200
Message-ID: <CAA9_cmdx7T2jnfw6TvL0_3ytfs-h-X06uF3_7Ex-YP12YKpwng@mail.gmail.com>
Subject: Re: [PATCH v3 00/13] dax: fix dma vs truncate and remove 'page-less' support
Content-Type: multipart/alternative; boundary="001a1144a50cdc7c42055c85c780"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "jack@suse.cz" <jack@suse.cz>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "bfields@fieldses.org" <bfields@fieldses.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "paulus@samba.org" <paulus@samba.org>, "Hefty, Sean" <sean.hefty@intel.com>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "dledford@redhat.com" <dledford@redhat.com>, "hch@lst.de" <hch@lst.de>, "jgunthorpe@obsidianresearch.com" <jgunthorpe@obsidianresearch.com>, "hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

--001a1144a50cdc7c42055c85c780
Content-Type: text/plain; charset="UTF-8"

[replying from my phone, please forgive formatting]

On Friday, October 27, 2017, Dave Chinner <david@fromorbit.com> wrote:


> > Here are the two primary patches in
> > the series, do you think the extent-busy approach would be cleaner?
>
> The XFS_DAXDMA....
>
> $DEITY that patch is so ugly I can't even bring myself to type it.


Right, and so is the problem it's trying to solve. So where do you want to
go from here?

I could go back to the FL_ALLOCATED approach, but use page idle callbacks
instead of polling for the lease end notification. Or do we want to try
busy extents? My concern with busy extents is that it requires more per-fs
code.

--001a1144a50cdc7c42055c85c780
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div><br></div>[replying from my phone, please forgive formatting]<br><br>O=
n Friday, October 27, 2017, Dave Chinner &lt;<a href=3D"mailto:david@fromor=
bit.com">david@fromorbit.com</a>&gt; wrote:<div>=C2=A0</div><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pa=
dding-left:1ex">
&gt; Here are the two primary patches in<br>
&gt; the series, do you think the extent-busy approach would be cleaner?<br=
>
<br>
The XFS_DAXDMA....<br>
<br>
$DEITY that patch is so ugly I can&#39;t even bring myself to type it.</blo=
ckquote><div><br></div><div>Right, and so is the problem it&#39;s trying to=
 solve. So where do you want to go from here?</div><div><br></div><div>I co=
uld go back to the FL_ALLOCATED approach, but use page idle callbacks inste=
ad of polling for the lease end notification. Or do we want to try busy ext=
ents? My concern with busy extents is that it requires more per-fs code.</d=
iv>

--001a1144a50cdc7c42055c85c780--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
