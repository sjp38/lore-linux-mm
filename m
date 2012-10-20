Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 32CAE6B0062
	for <linux-mm@kvack.org>; Sat, 20 Oct 2012 08:42:34 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so905632qcq.14
        for <linux-mm@kvack.org>; Sat, 20 Oct 2012 05:42:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121019233632.26cf96d8@sacrilege>
References: <20121019205055.2b258d09@sacrilege>
	<20121019233632.26cf96d8@sacrilege>
Date: Sat, 20 Oct 2012 08:42:33 -0400
Message-ID: <CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
From: Paul Moore <paul@paul-moore.com>
Content-Type: multipart/alternative; boundary=047d7bdc04fa47e61d04cc7cf468
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kazantsev <mk.fraggod@gmail.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org

--047d7bdc04fa47e61d04cc7cf468
Content-Type: text/plain; charset=ISO-8859-1

Thanks for the problem report.  I'm not going to be in a position to start
looking into this until late Sunday, but hopefully it will be a quick fix.

Two quick questions (my apologies, I'm not able to dig through your logs
right now): do you see this leak on kernels < 3.5.0, and are you using any
labeled IPsec connections?

--
paul moore
www.paul-moore.com

--047d7bdc04fa47e61d04cc7cf468
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">Thanks for the problem report.=A0 I&#39;m not going to be in=
 a position to start looking into this until late Sunday, but hopefully it =
will be a quick fix.</p>
<p dir=3D"ltr">Two quick questions (my apologies, I&#39;m not able to dig t=
hrough your logs right now): do you see this leak on kernels &lt; 3.5.0, an=
d are you using any labeled IPsec connections?</p>
<p dir=3D"ltr">--<br>
paul moore<br>
<a href=3D"http://www.paul-moore.com">www.paul-moore.com</a></p>

--047d7bdc04fa47e61d04cc7cf468--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
