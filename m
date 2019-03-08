Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5755BC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 16:22:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1930520657
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 16:22:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tycho-ws.20150623.gappssmtp.com header.i=@tycho-ws.20150623.gappssmtp.com header.b="SG7C/hir"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1930520657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.ws
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7C5E8E0004; Fri,  8 Mar 2019 11:22:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B55398E0002; Fri,  8 Mar 2019 11:22:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A43368E0004; Fri,  8 Mar 2019 11:22:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5D78E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 11:22:41 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id d18so28309707ywb.2
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 08:22:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WzKuwNcoBCL9U3oKIOmrzCFFAxc+z1LWxRP1k9/QX/E=;
        b=qeNIpmhuEcidiNb+q36B1bhjQjh9Q40MuLVGXUSPTodE4QAaREhPttqk1PK9RxYFKI
         zwEDSiorLTc8A9urRDT7wtyr2waWtXozRiwtx6i8nV1K5Aj24DZhX+yY44Co/BO71k5D
         ThN47SozaEpmjeWXhytx6jldHTlOdv8zxyub5zC6WLm5dmaMnPfrWSkvujqVs2/Y0+0i
         6LcSfgT79UWqDCOh7ULupPxkVDXqAKUN8kvx12jRy2sc6K4y7zAE6JBPguESmjNdK1iz
         I2AiOvCLKuQP8juTTN3/EeIoUr64xXxk1ng58CGXI+bMNCboPsAjF7kRtpYzKH2DU82T
         /42g==
X-Gm-Message-State: APjAAAWv0X5mZwWfS6BisJ/XC+HnJZjJiOWxZyXlKN6N0QHmQwJsd3ot
	6yjWJg97XYXrFVl1SDmhHb08WZNEGQmNwAELG7K/ilLv23vXKmq8C3e8Alhlm/3+3gy72P2iN76
	gNiZZSJu0DgQ3FgAKiz0brZvz6/6eVKfxzvsSqwFWKusZznUMTGRQ3Bq3xETYJW7c54Rn8RLHzz
	IZaIVB6IsSda49FUCCb9fkvLj5u3fFL5lT86TBjXvLy9eejOMakYcTo69+kjJ+S0vhYNCf24QXO
	Qk33JISJ+kzjTTbc3nnKjovJS/f/FOYq69e/EZ/n07YvAipAExCA4HHMTCZ3DrHzz1fBYlIa/+5
	uv+quEXMb+aW6IfktKo5bWouG62r+OKKUKSvKzDv1lUfVJDxCeHH8NPpPgJP9eSdU/+zfWSjqBS
	/
X-Received: by 2002:a0d:ca4c:: with SMTP id m73mr15195568ywd.377.1552062161138;
        Fri, 08 Mar 2019 08:22:41 -0800 (PST)
X-Received: by 2002:a0d:ca4c:: with SMTP id m73mr15195510ywd.377.1552062160446;
        Fri, 08 Mar 2019 08:22:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552062160; cv=none;
        d=google.com; s=arc-20160816;
        b=HBUx4S4gCgZS3hdTXQd7veSW62Z5lyc+6S8mFCJpqdRHMmCCG9oM6uxrMWs0N/nZy/
         WpZhQkF/37N6D+VHAqKrIoO+MDQdcgSZVMWz1qSLKLvuskUHQ4GkWSvVMeL7FAV+Fq0x
         Xi+BDeY88AyPjrn9ylEH/FcTJn3F0wKW1OI1TDGk2kMnO/Z3rZvoIoQxegxb2wPz0V4H
         DEKPSnbZjtYIGS94B5PwIz0GbS/bRdZv5iR6gWz+LLFDqvrZptjwOP9/0CRKGAjk2huR
         fb1y/HIAo3nfqE/cP7iGY01kdxVkMlYlURU7pT6T+s7tAAUCn9KswcMKf44/WggIotwM
         w/PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WzKuwNcoBCL9U3oKIOmrzCFFAxc+z1LWxRP1k9/QX/E=;
        b=qIdhK2hdPdmM9ux8O3CmOL4khljPOMPbN+JZQ7CG4bff/CIBn5P2tDw99CtuB1RnXj
         IPmKkep1vFgQRWohHlYbdAlCPJUSdesADxfr3IPzVuFjk8ccTdPToNu+ZEK2PhqM6WGI
         v3lvls0brMu1z7O6r/tz9HM+jepoevzsYoSwqZYX6lhKLEd+4ajffa8g4ugYsyj6mtfJ
         d6l8h3cYf8R231eXbr/vLUuBJGL9uYGXNFGdqgNe22oGF1XNMf4ZIZFXkjDUYVeDEKP1
         y8fKh/osnwdKT06ltD58pSzYG3eqvZ1N8lkOkErR8bgNTl5hY1MdkDX+fsba/7jtW3H1
         X0ww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b="SG7C/hir";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o186sor458600ywc.191.2019.03.08.08.22.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 08:22:40 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b="SG7C/hir";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tycho-ws.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=WzKuwNcoBCL9U3oKIOmrzCFFAxc+z1LWxRP1k9/QX/E=;
        b=SG7C/hirBfsngAx8tMYp7iQ2Mn1Ob3ERIllqoGDkUqsdKmlsr3niO9F1qYEdWlXJT5
         5huxqo+SBPoSaFESP33Fr+t4Rzc7tBcT53NFWE97GDftecwMEGLtMcJEKzTlYzhpLnjp
         PuLBtdeQPLuJdl/1xPm2jytSmlRCT7HODg/Q4SaxZOhoIjCr+nOrurOhGAUQvxjBushv
         VSshXN4DTpsbkqebvP8BaJ2f/1P8BVWJKOUfKhPy+hFhz8NyRj2qwYNuhG8S+244L3mg
         2rsJQLWJNet7OgegqzSPFhMr6SnTVwIdJM6Qx0Qe8hkfgjqe61Vb5dvKJ37kp0Yb39/1
         JBTw==
X-Google-Smtp-Source: APXvYqybyQpoib8PQzxv71EAfMfQyD8hak5sv0O2aTEddKGWaVGDr90e5pRzxkWR369jDKk+hsc2Jw==
X-Received: by 2002:a81:78d6:: with SMTP id t205mr15398565ywc.181.1552062159853;
        Fri, 08 Mar 2019 08:22:39 -0800 (PST)
Received: from cisco ([2601:282:901:dd7b:316c:2a55:1ab5:9f1c])
        by smtp.gmail.com with ESMTPSA id h204sm3082190ywh.52.2019.03.08.08.22.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Mar 2019 08:22:39 -0800 (PST)
Date: Fri, 8 Mar 2019 09:22:37 -0700
From: Tycho Andersen <tycho@tycho.ws>
To: Christopher Lameter <cl@linux.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC 02/15] slub: Add isolate() and migrate() methods
Message-ID: <20190308162237.GD373@cisco>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-3-tobin@kernel.org>
 <20190308152820.GB373@cisco>
 <010001695e16cdef-9831bf56-3075-4f0e-8c25-5d60103cb95f-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010001695e16cdef-9831bf56-3075-4f0e-8c25-5d60103cb95f-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 04:15:46PM +0000, Christopher Lameter wrote:
> On Fri, 8 Mar 2019, Tycho Andersen wrote:
> 
> > On Fri, Mar 08, 2019 at 03:14:13PM +1100, Tobin C. Harding wrote:
> > > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > > index f9d89c1b5977..754acdb292e4 100644
> > > --- a/mm/slab_common.c
> > > +++ b/mm/slab_common.c
> > > @@ -298,6 +298,10 @@ int slab_unmergeable(struct kmem_cache *s)
> > >  	if (!is_root_cache(s))
> > >  		return 1;
> > >
> > > +	/*
> > > +	 * s->isolate and s->migrate imply s->ctor so no need to
> > > +	 * check them explicitly.
> > > +	 */
> >
> > Shouldn't this implication go the other way, i.e.
> >     s->ctor => s->isolate & s->migrate
> 
> A cache can have a constructor but the object may not be movable (I.e.
> currently dentries and inodes).

Yep, thanks. Somehow I got confused by the comment.

Tycho

