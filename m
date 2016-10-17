Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 47F026B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 13:32:00 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m5so135428705qtb.3
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 10:32:00 -0700 (PDT)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id k71si18415278qke.306.2016.10.17.10.31.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 10:31:59 -0700 (PDT)
Received: by mail-qk0-x234.google.com with SMTP id z190so247346832qkc.2
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 10:31:59 -0700 (PDT)
Content-Type: multipart/alternative; boundary="Apple-Mail=_A44A4F5A-9396-4DFF-BC1C-D7F7E50ECCED"
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [RFC] scripts: Include postprocessing script for memory allocation tracing
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <CANnt6X=RpSnuxGXZfF6Qa5mJpzC8gL3wkKJi3tQMZJBZJVWF3w@mail.gmail.com>
Date: Mon, 17 Oct 2016 13:31:57 -0400
Message-Id: <A6E7231A-54FF-4D5C-90F5-0A8C4126CFEA@gmail.com>
References: <20160911222411.GA2854@janani-Inspiron-3521> <20160912121635.GL14524@dhcp22.suse.cz> <0ACE5927-A6E5-4B49-891D-F990527A9F50@gmail.com> <20160919094224.GH10785@dhcp22.suse.cz> <BFAF8DCA-F4A6-41C6-9AA0-C694D33035A3@gmail.com> <20160923080709.GB4478@dhcp22.suse.cz> <E8FAA4EF-DAA1-4E18-B48F-6677E6AFE76E@gmail.com> <2D27EF16-B63B-4516-A156-5E2FB675A1BB@gmail.com> <20161016073340.GA15839@dhcp22.suse.cz> <CANnt6X=RpSnuxGXZfF6Qa5mJpzC8gL3wkKJi3tQMZJBZJVWF3w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--Apple-Mail=_A44A4F5A-9396-4DFF-BC1C-D7F7E50ECCED
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8


> On Oct 17, 2016, at 1:24 PM, Janani Ravichandran =
<janani.rvchndrn@gmail.com> wrote:
>=20
>=20
> On Sun, Oct 16, 2016 at 3:33 AM, Michal Hocko <mhocko@kernel.org =
<mailto:mhocko@kernel.org>> wrote:
>=20
> trace_mm_page_alloc will tell you details about the allocation, like
> gfp mask, order but it doesn't tell you how long the allocation took =
at
> its current form. So either you have to note jiffies at the allocation
> start and then add the end-start in the trace point or we really need
> another trace point to note the start. The later has an advantage that
> we do not add unnecessary load for jiffies when the tracepoint is
> disabled.

The function graph tracer can tell us how long alloc_pages_nodemask() =
took.
Can=E2=80=99t that, combined with the context information given by =
trace_mm_page_alloc
give us what we want? Correct me if I am wrong.

Regards,
Janani.

> --
> Michal Hocko
> SUSE Labs
>=20


--Apple-Mail=_A44A4F5A-9396-4DFF-BC1C-D7F7E50ECCED
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D""><br class=3D""><div><blockquote type=3D"cite" class=3D""><div =
class=3D"">On Oct 17, 2016, at 1:24 PM, Janani Ravichandran &lt;<a =
href=3D"mailto:janani.rvchndrn@gmail.com" =
class=3D"">janani.rvchndrn@gmail.com</a>&gt; wrote:</div><div =
class=3D""><div dir=3D"ltr" class=3D""><br class=3D""></div><div =
class=3D"gmail_extra"><br class=3D""><div class=3D"gmail_quote">On Sun, =
Oct 16, 2016 at 3:33 AM, Michal Hocko <span dir=3D"ltr" class=3D"">&lt;<a =
href=3D"mailto:mhocko@kernel.org" target=3D"_blank" =
class=3D"">mhocko@kernel.org</a>&gt;</span> wrote:<blockquote =
class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex"><span class=3D"">
<br class=3D"">
</span>trace_mm_page_alloc will tell you details about the allocation, =
like<br class=3D"">
gfp mask, order but it doesn't tell you how long the allocation took =
at<br class=3D"">
its current form. So either you have to note jiffies at the =
allocation<br class=3D"">
start and then add the end-start in the trace point or we really need<br =
class=3D"">
another trace point to note the start. The later has an advantage =
that<br class=3D"">
we do not add unnecessary load for jiffies when the tracepoint is<br =
class=3D"">
disabled.<br =
class=3D""></blockquote></div></div></div></blockquote><div><br =
class=3D""></div>The function graph tracer can tell us how long =
alloc_pages_nodemask() took.</div><div>Can=E2=80=99t that, combined with =
the context information given by trace_mm_page_alloc</div><div>give us =
what we want? Correct me if I am wrong.</div><div><br =
class=3D""></div><div>Regards,</div><div>Janani.</div><div><br =
class=3D""></div><div><blockquote type=3D"cite" class=3D""><div =
class=3D""><div class=3D"gmail_extra"><div =
class=3D"gmail_quote"><blockquote class=3D"gmail_quote" style=3D"margin:0 =
0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<div class=3D"HOEnZb"><div class=3D"h5">--<br class=3D"">
Michal Hocko<br class=3D"">
SUSE Labs<br class=3D"">
</div></div></blockquote></div><br class=3D""></div>
</div></blockquote></div><br class=3D""></body></html>=

--Apple-Mail=_A44A4F5A-9396-4DFF-BC1C-D7F7E50ECCED--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
