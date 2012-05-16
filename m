Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 658AD6B0081
	for <linux-mm@kvack.org>; Wed, 16 May 2012 11:17:47 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so1651655obb.14
        for <linux-mm@kvack.org>; Wed, 16 May 2012 08:17:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120516145032.GA1139@kroah.com>
References: <1337108498-4104-1-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1205151527150.11923@router.home>
	<alpine.LFD.2.02.1205160935340.1763@tux.localdomain>
	<CAAmzW4PWQiKbs+mdnwG18R=iWHLT=4Bwn8iA110PJaKuvG_AQQ@mail.gmail.com>
	<20120516145032.GA1139@kroah.com>
Date: Thu, 17 May 2012 00:17:46 +0900
Message-ID: <CAAmzW4PA26qX8H1boKaHSh0m0S-aw7CVCTMeeijS-rCQEQzUdQ@mail.gmail.com>
Subject: Re: [PATCH] slub: fix a memory leak in get_partial_node()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

2012/5/16 Greg Kroah-Hartman <gregkh@linuxfoundation.org>:
>> I read stable_kernel_rules.txt, this article tells me I must note
>> upstream commit ID.
>> Above patch is not included in upstream currently, so I can't find
>> upstream commit ID.
>> Is 'Acked-by from MAINTAINER' sufficient for submitting to stable-kernel=
?
>> Is below format right for stable submission format?
>
> No.
>
> Please read the second item in the list that says: "Procedure for
> submitting patches to the -stable tree" in the file,
> Documentation/stable_kernel_rulest.txt. =A0It states:
>
> =A0- To have the patch automatically included in the stable tree, add the=
 tag
> =A0 =A0 Cc: stable@vger.kernel.org
> =A0 in the sign-off area. Once the patch is merged it will be applied to
> =A0 the stable tree without anything else needing to be done by the autho=
r
> =A0 or subsystem maintainer.
>
> Does that help?
>
> thanks,
>
> greg k-h

Thanks, very helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
