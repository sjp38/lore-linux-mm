Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DCB4C43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 11:53:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E62F8206B7
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 11:53:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hzaFXs+1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E62F8206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A4C68E0077; Tue,  8 Jan 2019 06:53:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82C348E0038; Tue,  8 Jan 2019 06:53:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71AFA8E0077; Tue,  8 Jan 2019 06:53:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 03B6E8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 06:53:48 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id z5-v6so885230ljb.13
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 03:53:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bqIv+E1PTwowFq29pJyeluAn6z1FULnn8P66wo1yneY=;
        b=YrvWNcqWMBCWpVriQjJmjYb9eGpUwYRwCZc9mYHoOh0mP3bo8sArV/5MklWeJAMuJt
         eC0eqQKjyXrPmAob1gAf9JqRt8quO784QflTrDe+zumu8G1NMQIt1zjH8DfOf91fQOgq
         ZIs3k+49WCM90Hai1ylEeEIsqzyVGXfoAtLDfdHYupGmAcEgVDb638mSerbBZs6t3wET
         6eFaLFfwLgU4JXCIYp9RULl0Dz5O0Qt2xV9PRhWp6dwkhz1AbVBYKj+ZFCj0As4pCYnk
         I/vl9NccWxcGG7lMNGFteDdi/TeMJ7KA4iUA2rN2dKgRuUem+Cn+K+FTycn07J6/cC04
         xbKA==
X-Gm-Message-State: AJcUukdKvkLsc8ysQPH11yNgAVyk4rmwaWVRu4qcfIpYKzGuPu12Evfe
	VQpLrM4j/SN0Aghh2PeLGLYx1rpQtYNrc+1dB1DLFHKfOV8N+jMuwxEusoO3QAmPdTh5H8d7DT3
	E/SfBUePv9o+JPVMXG0CAvKuiitdtdbE2KIfIgWZuepDBvYre8IRMDqwQEWewY3cC6n/GEL/QTH
	UrJmeIi8Mg69tm1IJtdRF6GNL2IL20F2jsA+fzHPdfJfrLwh7RzuAUBQUVt0UQ/Guzidby2tMLx
	Tjt1WDVng58sSiOWSpFo5MynW/LQGHezpa4ekFSftcdm2nYJqlpcBG3pgLp2CeJ1sBjyA7h23Ht
	xixPnwA1QR7vFQumSFjTIUKs3RltqThKF8+3Pqqb+haFiPuZVb8s/mRLfF6lqliI/j1+ADFxccs
	D
X-Received: by 2002:a2e:92ca:: with SMTP id k10-v6mr874382ljh.63.1546948427100;
        Tue, 08 Jan 2019 03:53:47 -0800 (PST)
X-Received: by 2002:a2e:92ca:: with SMTP id k10-v6mr874358ljh.63.1546948426216;
        Tue, 08 Jan 2019 03:53:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546948426; cv=none;
        d=google.com; s=arc-20160816;
        b=xefWG4oK2ZWKV1hRDg9vv3yh6KNn8DazYV6hCUZSYvmaJXKu/eywNpWijSYqiWJv61
         K+nNa6KkXA/Ia6KHq7qWEtr/W9TEeMFOv/KLol//U/Y2hgsswoXd7ZRztiuA9Jb3Pezm
         +B3i/QV6OM77rDOWwTbyLoYEHRZZyO5wslJDG/NyAV7vJznhyVTzxQIW+oOpfPvtc7Uf
         wpsRwE9X6CHUipJZGxv+aFgeuyqVd0BSOaTjSfc2CyYSM5L7ggq57K6Pn2PHkefnsQxO
         QaeqeCx9PJDnDa3Z7fhl+Ndu/FhPYgVgBSi2cwMBvAFfP7BTkMVhTLqxCJuaJRwDv4bh
         YOLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bqIv+E1PTwowFq29pJyeluAn6z1FULnn8P66wo1yneY=;
        b=pV1s8q9oDtAXnthrBAr6YRYA39ePn9W8cq3zAtJiMrWHkgGW4kGA4ORTdVjd2cI1U6
         1LKpMCYGpp0EGGTQ3lcNgA6/WfA4lWwmfEeDiPyP4FRDlc1/A7eOajnmhzXufj+2npP5
         P+JhGzdAXpbccSTkmpTJR5RjXBrjlV+AJ7kkE+t+86oaOTU4sapBNFr+sNPHkl6ehtKQ
         yo7yMhkq9DsDqlKwPupmk1gxny6UIybmq0KHcKfDYI2Ds9m5F019meG1jUAEeMIp8Q5S
         RiQVYoXyIJ1/ThqZYND83JaSw4lbTK0LXjgZIuNe+9RMfedf5Oq9ZrjnIQ7gjC89Tsp2
         hmJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hzaFXs+1;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a16sor17262709lfi.3.2019.01.08.03.53.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 03:53:46 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hzaFXs+1;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bqIv+E1PTwowFq29pJyeluAn6z1FULnn8P66wo1yneY=;
        b=hzaFXs+1llc+1muA3yyF5s58PrkUU/rP2QcIc33UROR8Mczohrq2+R9qZlyUpF8ez+
         qc9y8zeDs+vfHPv5h2iFaao3R3NaLCKs9kg7wLweGKWt9pSFg2B5KIuWcJb91t8dn73k
         qaV/jynuTy/eqO4euurFpaTQ2ye+A2Oty/yWdocurYIKsAIKep3DoN9+BbjLzJ9eVmQp
         lWr9GnZckeSnRRd3oxBASpCWtml31eJrdiBa4lrJi8ejJmDHSZ81qdd/GqFWYNgJ36i1
         vX6lbuUKdgjOPDgVIHjyOdBLEU8P0UUDPC8dL4/LPE6320932zAcVBogDMp77N7P7eHx
         L49A==
X-Google-Smtp-Source: ALg8bN6asg4ACjm+I/qsuDyaEhCsFPFZT3hyb5lBBFPcZSESc56cWvPZ3LwnZlXIyw14QmlSLeYw6oo2vkz5P2NUX+o=
X-Received: by 2002:a19:c396:: with SMTP id t144mr838044lff.110.1546948425677;
 Tue, 08 Jan 2019 03:53:45 -0800 (PST)
MIME-Version: 1.0
References: <20181106120544.GA3783@jordon-HP-15-Notebook-PC>
 <20181115014737.GA2353@rapoport-lnx> <CAFqt6zbOgSm9omt+6iV0GJtZdZ_qyTr9Jte9ZGYRQ1M4CdB-mA@mail.gmail.com>
 <CAFqt6zZ67tFA8FjFZ4xM+YUAez9EdPHinx0ky0X5sQHyZ9nkLg@mail.gmail.com>
 <CAFqt6zYY=xfqvVxRi1spbMNzvoM_CYNxbm6d7_79a5bBHxUzuA@mail.gmail.com> <20190107144411.b3e2313649f106de0776432e@linux-foundation.org>
In-Reply-To: <20190107144411.b3e2313649f106de0776432e@linux-foundation.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 8 Jan 2019 17:23:33 +0530
Message-ID:
 <CAFqt6zZV-9qJYbKDbCNR1AkmeCVFWrJ2i270=w0i3jNEnN_nvw@mail.gmail.com>
Subject: Re: [PATCH v3] mm: Create the new vm_fault_t type
To: Andrew Morton <akpm@linux-foundation.org>
Cc: rppt@linux.ibm.com, Michal Hocko <mhocko@suse.com>, 
	Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, riel@redhat.com, 
	Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108115333.tQWIffLGGlYPe2JGgTwqS9QGRu2ley5TNlE4E8KOTJs@z>

On Tue, Jan 8, 2019 at 4:14 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Mon, 7 Jan 2019 11:47:12 +0530 Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> > > Do I need to make any further improvement for this patch ?
> >
> > If no further comment, can we get this patch in queue for 5.0-rcX ?
>
> I stopped paying attention a while ago, sorry.
>
> Please resend everything which you believe is ready to go.

Sure, I will resend. no prob :)

