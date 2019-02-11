Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12E28C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 07:43:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C03A920811
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 07:43:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vQXX5IB2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C03A920811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F9518E00CF; Mon, 11 Feb 2019 02:43:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A8178E00C4; Mon, 11 Feb 2019 02:43:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 170808E00CF; Mon, 11 Feb 2019 02:43:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C60778E00C4
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 02:43:17 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w20so8731775ply.16
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 23:43:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LzdxB19zhApMwZH0H6vEn1LPmCbo2CeSOy3HttPM3Rk=;
        b=RqN+BDCxtIKavFqf133vhnwqMgibU4j0PwXE9sKEwumOFoIkxHrtDdNYPjw4tZr9cz
         M0Vq0xm928eaZetpdsnIqfJoQ86GGDdLViJN9I/TCkAxQd0cmgBDSt0ntUqhgbxDy90n
         Ida/mO9ckObLTZR77jgN62fiDkUWMoj25blroTG0KlfUSjbaj0PionY7NF83n0d/94uo
         digM2mhvyXiUK3S4e9H5tFmsTP19rWbX67dAeXIVioQaBxuyiAD2rlDJHBfSxlrDQHw1
         Ya9SCZgsC4+Kc90KxLatbR29TquIFEwmdBfmfc8iRp88Vxkxej8KwmQh989uEo/BLzMp
         q7xg==
X-Gm-Message-State: AHQUAua851xBBbS8Z+WHENi0QliE4DcW/yAyDs/zeNNuFae3DqiaySax
	Cd2jgXHg1LsulTxyoguvcoxOnLX2cStt9Tv0YfeDlkmb8f53jHh0ZgN1x4t5x5UQaem/k9sfWQO
	nCs+97kbyIiHrUycVZidvntHPdpFzSYjZI995ksaJjeEq+xWuf8hg40S11iOqF9BOoG5ki/1sVS
	0BAjaAqsMNn8VMX4wbcRlAwpujxZ0lJhm5sUHzH1z6RfdtcsanuJDjCocs6WZYAgKCYMaYTzzcL
	HN1oyW3vAXsiSkx8rx916Wm7HK1actjq6qFtUUX0erUBbt4sVtVI/mVsLfZ3IgaDfTBhCmTzC9u
	+Y++NYYN5Sdltw1gIoSmkgrAgU6+veFr7CYyBYaNiNDGNndfveT0sHlJKtKg9ert6kPTDY1afdL
	c
X-Received: by 2002:a65:6215:: with SMTP id d21mr32526630pgv.289.1549870997416;
        Sun, 10 Feb 2019 23:43:17 -0800 (PST)
X-Received: by 2002:a65:6215:: with SMTP id d21mr32526614pgv.289.1549870996799;
        Sun, 10 Feb 2019 23:43:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549870996; cv=none;
        d=google.com; s=arc-20160816;
        b=lT5iQQL6Lb10Uc3t9lVf+XHvvuq8pzmCvb2+zpujDWRRrqrlogVzjzKHQ1+r4cvWdf
         VKa8u4281uHM3RDzHOFIaHSkPric1XaUPNWLovIOPN9nx2ppihc3BAFSxEBjIfEZGLa7
         UFxUesUNtnYtap6ooDNZdy9fdoJGbnDqXPd1uSPej0KhcNPys5UmZnfmNM1ccPaz3dQ/
         AIqS0sbarQ12WKdf4nRyziMLKDUNNAavvt6Auu7oep39pHLjOEKrFx5A9R5+MC4j3Cgk
         UBXWigApf4C1O9fYkLJqQ7YSczBnOb1jyPvqME1nzpGS3wekmGuctiAOe/eBcICtJTDl
         1lCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LzdxB19zhApMwZH0H6vEn1LPmCbo2CeSOy3HttPM3Rk=;
        b=YXjdBfft4Z7JdFVoQy5CZ70zK1PMd5B713S7awOjdWpOTjN2LxPnnzwaJaQ3RI+V1N
         zthBQCA83rG2tul0E1r8745gcZiQSj+JJfF1SIwIZ1rGlpl+2O0CKlsINU6B9Bh2HzFq
         R05y0MmB11XnApNbtg2c+rx/DkXla9fNmLp8C6mZ4xrmUO8CI/kqMUgEjmbRE80ULvXS
         MQE5CYwrfTAWVSrJGLtwzNIpQt0XiTQeBHPnfgb+nNDP7+bJLb2xgSaDj6Y2AVK6FRSA
         72pbRZFHH9jqOyWFXXCmPDPiPXJB0lqfJ6BlZYQeOynMaWaNur2124pgKjM0AYhRBYk5
         ZqYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vQXX5IB2;
       spf=pass (google.com: domain of sergey.senozhatsky.work@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sergey.senozhatsky.work@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6sor13235376plq.70.2019.02.10.23.43.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Feb 2019 23:43:16 -0800 (PST)
Received-SPF: pass (google.com: domain of sergey.senozhatsky.work@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vQXX5IB2;
       spf=pass (google.com: domain of sergey.senozhatsky.work@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sergey.senozhatsky.work@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=LzdxB19zhApMwZH0H6vEn1LPmCbo2CeSOy3HttPM3Rk=;
        b=vQXX5IB20a2Re4fUEbSuRpgaZX4KGwVOHSTJWplqnNZf+8Y7r/l1ONh6IHkDNA/Hdk
         z4jy8vmTkP0N8GPyswCSk7dZkh4GpRNyvSP+7GFwGQ3NB1CwAUCKztvNaS37l+aTRjE9
         XGRKCtF/TDhLHml8qClvXaoORE2FZvSgzDJ+RB/xyyo53aT24zEsbPs3i/bBcVqpouO5
         mHRXz8GLZfJSYshQLLWnsIob2pZSHLkbzbpPlPUXA0yg2OITeDEpXfInkfKtTcnZxDs4
         vVBOpFe+QLlo5RH60Dae8kxggrxrtJ7c/qrPDyvObgEkLDnc5bAGcXiogTGN8FR7mzNz
         l30w==
X-Google-Smtp-Source: AHgI3Iaf1MpBbJJ8uTMAYdhLdQxO4kI5hHbwP4MylJcKIuOLER1MTDBVTSxWgqEvQA/FP/c65uS2YA==
X-Received: by 2002:a17:902:2bc9:: with SMTP id l67mr1863808plb.241.1549870996468;
        Sun, 10 Feb 2019 23:43:16 -0800 (PST)
Received: from localhost ([175.223.48.87])
        by smtp.gmail.com with ESMTPSA id a90sm17164079pfj.109.2019.02.10.23.43.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 10 Feb 2019 23:43:15 -0800 (PST)
Date: Mon, 11 Feb 2019 16:43:12 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jonathan Corbet <corbet@lwn.net>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	Christoph Lameter <cl@linux.com>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] Documentation: fix vm/slub.rst warning
Message-ID: <20190211074312.GA26364@jagdpanzerIV>
References: <1e992162-c4ac-fe4e-f1b0-d8a16a51d5e7@infradead.org>
 <20190211073537.GA25868@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211073537.GA25868@rapoport-lnx>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (02/11/19 09:35), Mike Rapoport wrote:
> On Sun, Feb 10, 2019 at 10:34:11PM -0800, Randy Dunlap wrote:
> > From: Randy Dunlap <rdunlap@infradead.org>
> > 
> > Fix markup warning by quoting the '*' character with a backslash.
> > 
> > Documentation/vm/slub.rst:71: WARNING: Inline emphasis start-string without end-string.
> > 
> > Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> > Cc: Christoph Lameter <cl@linux.com>
> > Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> 
> Acked-by: Mike Rapoport <rppt@linux.ibm.com>

FWIW,
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

