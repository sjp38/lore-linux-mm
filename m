Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E861C282CC
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 15:49:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E58D92177B
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 15:49:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E58D92177B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=acm.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F14C8E0093; Fri,  8 Feb 2019 10:49:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 777288E0002; Fri,  8 Feb 2019 10:49:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 617D98E0093; Fri,  8 Feb 2019 10:49:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 19B2C8E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 10:49:51 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id j132so2697633pgc.15
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 07:49:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FMzGy6XshdWiGg39MNWPhorgETSh6qReqAZKsddUeJY=;
        b=YGSlV8K3sO0fcyQGe5+ZG06APdfT7WI72vO2Szaf1eJ8r4JJ2k709iRvgCqxCmKZwE
         /FbMjoH72iB2I3pyELBOaf0vNXJY34XJqMcldCm5uzogn8cj83u+0whD89JmkxxrY2jL
         yWAGLuJpjNtSeEhPIz4RzJr/KA7jbRvVfy6tgGM8Fhp/Nkel9dtY0NS9Phzoy5DFoucV
         29YHvPpXPYcA1AXznPbpRiMDNjIgwR7Can0ngjbAGEob0sMDNijEHPmiLWuy7j8OMe4m
         gR+9ixtm+9ZHsZA2an54DRsrL8F7SHO7Y6oEN3s7Ulzz/jYJ4FXtzSNUvL+CtfXBWUkH
         E5lg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
X-Gm-Message-State: AHQUAuZQ/oNc39CSEucACgwWLL2D/32HdOrjMIoAzoPBaK1VPEBoXcuK
	WFlJ4vu0zyB+0KB5ltsOdYng2sEZhmnCba9pzUe10sJtrxXFguiFJHS9DCJr5Fu9Z9rUbEtgAam
	NEFWteDlOFSWwILyZEQ6sxb2XZPy4T7SlLRzYk7l2ASTcb07kxLLkzVMpp4TnIp8HulR/sDXKwX
	2zAnhc+JE0YSv3JlhSJ/JBhKBR+PCfT1zcshJtqUW2pNuQuA16ebK9ZSbZaUujwxIEkNCm4CJAh
	yt8WqJyNEjFj6HfLS5JJJKRwS5/qA7jNJtLM4N1pLSnk31DNhEs2Q/EnrvruCNUATDkh+bPN1vH
	wtQWvlM3xWw7IC7ytBrnqQiFTi4Fmq3AchRC4bmHYTQE2G2e7WP+etCq62C29GY0sfL76RGbQQ=
	=
X-Received: by 2002:a62:68c5:: with SMTP id d188mr23460220pfc.194.1549640990711;
        Fri, 08 Feb 2019 07:49:50 -0800 (PST)
X-Received: by 2002:a62:68c5:: with SMTP id d188mr23460165pfc.194.1549640989963;
        Fri, 08 Feb 2019 07:49:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549640989; cv=none;
        d=google.com; s=arc-20160816;
        b=Cy7kqoxvQMv3SM4Di4CXXpGHNeAUtTH0XD5X0vf5OyO9xqMl8NnjFPXudsexaD8yhS
         1fzdcs46+IJnaPgIzNcYV8vxj8wQ8jglaqqD4u5LtGNIeSrnOO0tCNOZewd33ii2RbNa
         4blFRZtuijt/TjitBd8MoQSoAwjWLNjDAq1F+NwEHVwQ4Dw2kll0m5cN5SynYY3nNLpr
         qlRHN8t9tEgQM6EPcvomgIVdm1ZfviSN+s015Y9lFPklQcrItAnPPOg/ZiVK7u2VYDpC
         hY6Mcy5voeXqwC+A9f5TS7TA0iL1YjjLS4MHviYeOlFmF+C86HZiFwkDxedFBU0SxuSy
         HjTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=FMzGy6XshdWiGg39MNWPhorgETSh6qReqAZKsddUeJY=;
        b=XEFkKk8/I8Rslb/WX02Gr1fE8DZszzv4cw7029+ZEdWhsRl3/dqWREeg41H7Rd0vdD
         W9VVffnrparurKa3fZAzNUq+67wwpjZqmFixmO8jEHP5qL8XytD6SttfVMlHytlmPPJZ
         1IS+LQgxuEmJ1pGdNKyok/Y+KJ7WNkHGvwHJvpeE3SEPPT+ruj7DGpT4sW1WbQjAzEbw
         VvhqYCoPhOJf2SxvZDFI8VuBEc8QTLgeSdAw/eXC0RjgfCv3WSXa/38Td/jquN8BK7Zp
         3BMzuYsM0pfwgsvvGHYQu+VwtZW/JTKm2X8mFXC3U46AqrBdaM9PxEPX+9+d5dAkKfYe
         Z7qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f13sor3384515pga.66.2019.02.08.07.49.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Feb 2019 07:49:49 -0800 (PST)
Received-SPF: pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
X-Google-Smtp-Source: AHgI3IaWMZTNClRldfOGnzX91Uc+YoZ9yGwucpm3tZr9RDtWfe8ij2+LBk77LmkHwi4jwbfT1rFe8A==
X-Received: by 2002:a63:f844:: with SMTP id v4mr16078996pgj.82.1549640989265;
        Fri, 08 Feb 2019 07:49:49 -0800 (PST)
Received: from ?IPv6:2620:15c:2cd:203:5cdc:422c:7b28:ebb5? ([2620:15c:2cd:203:5cdc:422c:7b28:ebb5])
        by smtp.gmail.com with ESMTPSA id x2sm5458013pfx.78.2019.02.08.07.49.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Feb 2019 07:49:48 -0800 (PST)
Message-ID: <1549640986.34241.78.camel@acm.org>
Subject: Re: dd hangs when reading large partitions
From: Bart Van Assche <bvanassche@acm.org>
To: Marc Gonzalez <marc.w.gonzalez@free.fr>, linux-mm <linux-mm@kvack.org>, 
	linux-block <linux-block@vger.kernel.org>
Cc: Jianchao Wang <jianchao.w.wang@oracle.com>, Christoph Hellwig
 <hch@infradead.org>, Jens Axboe <axboe@kernel.dk>, fsdevel
 <linux-fsdevel@vger.kernel.org>, SCSI <linux-scsi@vger.kernel.org>, Joao
 Pinto <jpinto@synopsys.com>, Jeffrey Hugo <jhugo@codeaurora.org>, Evan
 Green <evgreen@chromium.org>, Matthias Kaehlcke <mka@chromium.org>, Douglas
 Anderson <dianders@chromium.org>, Stephen Boyd <swboyd@chromium.org>, Tomas
 Winkler <tomas.winkler@intel.com>, Adrian Hunter <adrian.hunter@intel.com>,
 Alim Akhtar <alim.akhtar@samsung.com>, Avri Altman <avri.altman@wdc.com>,
 Bart Van Assche <bart.vanassche@wdc.com>, Martin Petersen
 <martin.petersen@oracle.com>,  Bjorn Andersson
 <bjorn.andersson@linaro.org>, Ming Lei <ming.lei@redhat.com>, Omar Sandoval
 <osandov@fb.com>,  Roman Gushchin <guro@fb.com>, Andrew Morton
 <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Date: Fri, 08 Feb 2019 07:49:46 -0800
In-Reply-To: <66419195-594c-aa83-c19d-f091ad3b296d@free.fr>
References: <f792574c-e083-b218-13b4-c89be6566015@free.fr>
	 <398a6e83-d482-6e72-5806-6d5bbe8bfdd9@oracle.com>
	 <ef734b94-e72b-771f-350b-08d8054a58f3@kernel.dk>
	 <20190119095601.GA7440@infradead.org>
	 <07b2df5d-e1fe-9523-7c11-f3058a966f8a@free.fr>
	 <985b340c-623f-6df2-66bd-d9f4003189ea@free.fr>
	 <b3910158-83d6-21fe-1606-33e88912404a@oracle.com>
	 <d082bdee-62e5-d470-b63b-196c0fe3b9fb@free.fr>
	 <5132e41b-cb1a-5b81-4a72-37d0f9ea4bb9@oracle.com>
	 <7bd8b010-bf0c-ad64-f927-2d2187a18d0b@free.fr>
	 <0cfe1ed2-41e1-66a4-8d98-ebc0d9645d21@free.fr>
	 <d91e8342-4672-d51d-1bde-74e910e5a959@free.fr>
	 <27165898-88c3-ab42-c6c9-dd52bf0a41c8@free.fr>
	 <66419195-594c-aa83-c19d-f091ad3b296d@free.fr>
Content-Type: text/plain; charset="UTF-7"
X-Mailer: Evolution 3.26.2-1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-02-08 at 16:33 +-0100, Marc Gonzalez wrote:
+AD4 Does anyone see what's going sideways in the no-flag case?

Hi Marc,

Does this problem only occur with block devices backed by the UFS driver
or does this problem also occur with other block drivers?

Thanks,

Bart.

