Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 8C2F46B0081
	for <linux-mm@kvack.org>; Thu, 10 May 2012 22:01:54 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so1847603wgb.26
        for <linux-mm@kvack.org>; Thu, 10 May 2012 19:01:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALYq+qRtt=zn9UBKiOx0Opw+G2rXegQMXY6t4ZafGFwP_qxdNQ@mail.gmail.com>
References: <CALYq+qRtt=zn9UBKiOx0Opw+G2rXegQMXY6t4ZafGFwP_qxdNQ@mail.gmail.com>
Date: Fri, 11 May 2012 11:01:52 +0900
Message-ID: <CALYq+qS8jc+d2w0Jfx5Ci0-KShrHTV=p0f_Py8g_17PSOauadw@mail.gmail.com>
Subject: [Linaro-mm-sig] [PATCH 1/3] [RFC] Kernel Virtual Memory allocation
 issue in dma-mapping framework
From: Abhinav Kochhar <kochhar.abhinav@gmail.com>
Content-Type: multipart/alternative; boundary=f46d04428c9cc4967c04bfb91e68
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>

--f46d04428c9cc4967c04bfb91e68
Content-Type: text/plain; charset=ISO-8859-1

With this add a new attribute that can be passsed to dma-mapping IOMMU apis
to differentiate between kernel and user allcoations.

diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h

index 547ab56..861df09 100644

--- a/include/linux/dma-attrs.h

+++ b/include/linux/dma-attrs.h

@@ -15,6 +15,7 @@ enum dma_attr {

        DMA_ATTR_WEAK_ORDERING,

        DMA_ATTR_WRITE_COMBINE,

        DMA_ATTR_NON_CONSISTENT,

+       DMA_ATTR_USER_SPACE,

        DMA_ATTR_MAX,

 };

--f46d04428c9cc4967c04bfb91e68
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p>With this add a new attribute that can be passsed to dma-mapping IOMMU a=
pis to differentiate between kernel and user allcoations.<br></p>
<p>diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h</p>
<p>index 547ab56..861df09 100644</p>
<p>--- a/include/linux/dma-attrs.h</p>
<p>+++ b/include/linux/dma-attrs.h</p>
<p>@@ -15,6 +15,7 @@ enum dma_attr {</p>
<p>=A0 =A0 =A0 =A0 DMA_ATTR_WEAK_ORDERING,</p>
<p>=A0 =A0 =A0 =A0 DMA_ATTR_WRITE_COMBINE,</p>
<p>=A0 =A0 =A0 =A0 DMA_ATTR_NON_CONSISTENT,</p>
<p>+ =A0 =A0 =A0 DMA_ATTR_USER_SPACE,</p>
<p>=A0 =A0 =A0 =A0 DMA_ATTR_MAX,</p>
<p>=A0};<br></p>

--f46d04428c9cc4967c04bfb91e68--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
