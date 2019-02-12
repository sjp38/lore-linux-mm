Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E77A7C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:54:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC7992080A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:54:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC7992080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BC1F8E0011; Tue, 12 Feb 2019 03:54:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36B198E0008; Tue, 12 Feb 2019 03:54:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25B6F8E0011; Tue, 12 Feb 2019 03:54:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C052F8E0008
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:54:32 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b3so1834782edi.0
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 00:54:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Yc6jcRupfPVocnuGrsELZLSJelvqe580Si91B1Z5Nsc=;
        b=MPPV3DZG31no1MHx/n3Xp/9yAIYoZQXD1rHB1AMjYo+JGnBt+Fqk7AlIjs8HEhDgMI
         ULD94CDs6NBVliygaWk1kxUAGra2LlJFxY6OzU/AS2b3z+1LS66tDcnt63xSrRh0t2/N
         VDvR3vAldb/dkQvoxwbBcL/uFBuRFbPjbeAE1yOmWNzrsBzX0FasbjYYOnjHKlmSc2Mx
         69YgMeU63Cwo+eQwCDpE2Zjeya91HUgtcPYhp5cbZ8H/qzeazmkAtxcff7438vYJICjZ
         KOG05irxLiA842gRnP51DQej4kUBJfH/xys5Ieu5lgAF+mK9czsVt6jLuQuzjsJ1/ylG
         9NJg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYB3IXcuAAxHiIB2qj5+nBN1WP+A5B1tQOx0R72Z7BP8sw0IHBg
	z0eTZ8YdBg51fT5m0NpV75GaK53gZFKAP/Cn/Ml1JJiKYfyvFGETvDUyvK/Ux3jBSj2gPpigwzZ
	qu/FZKwaLZKjoH/EdoWvEY9EEZw55u1nut3/ibURrCZ+3GWVVfW+lWjIGDne1BPA=
X-Received: by 2002:a17:906:5e01:: with SMTP id n1mr1774853eju.99.1549961672176;
        Tue, 12 Feb 2019 00:54:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IarYwE092K1kLDS4iJrsQLXWHirk0ImuEm5aCWestaWJfvrnT8uLj+tnXpSRIkSe2s+Evyh
X-Received: by 2002:a17:906:5e01:: with SMTP id n1mr1774807eju.99.1549961671121;
        Tue, 12 Feb 2019 00:54:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549961671; cv=none;
        d=google.com; s=arc-20160816;
        b=afmIVR9OBKDpeGUsv7rq7iNTfsbnxdOc6ZRrRzsnkMNtJsCDPh5S760Wk83eDho0ra
         aLHlRmuXSDFha4vq7Yq4gOTgX4ucbnNk4msIjzJn+QUpnLjQ7duBpiAtySRzlBXbk7Ak
         YcoFC5uBxMfyBlQk5gk/ciAGJSguYYnqjQ7mQbSGMyMnblBFcYOIxFMzJDDwNCH1vXeX
         dYlbPOb8JNIywI3veazp0V2zMEcruaNXvfjNUk1jp/RH+ACMikUsLGoq9IYYH+aVlJkf
         WqYzXi2pDZ/hVBjYCIesYtWXwjRNzNVNw0XTHfh5MoBc9S92wHlHSAn6i+lcfLVzD+mT
         WbnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Yc6jcRupfPVocnuGrsELZLSJelvqe580Si91B1Z5Nsc=;
        b=GuEaAGQ175vgN6u3JzUPIGs6IFrxtN+4JrggmEcTjZYIb+uMeg2Mt5lCUtbfjKoM9G
         gTL5Az6cRo0+1SXDMKESvHFkjg2ODsxt2KZoVD8SsCh7lYWfflzmG9DIVDT9+TRgIA5b
         8qimdG4YciJZ+jU4cPDC6ODO6TqyS2W/+le9IIRJva0+dQ/OAd8la3nLTU9y56hcwQ1U
         Ni1Bl0ZqkEW92Yn89dlfQt8IXmDRnJS1fSU9uZqLUccOFoc5fSQHuCOomO6oDJqF9FZp
         8jZY57MgTx5yP+PuOAhu6xFsQ/Om/stqc2cDc7HdFiT8rof6GOjNp696sjLheBywlgOJ
         ubfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p11si2853799ejq.186.2019.02.12.00.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 00:54:31 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9E1F6AFA5;
	Tue, 12 Feb 2019 08:54:30 +0000 (UTC)
Date: Tue, 12 Feb 2019 09:54:28 +0100
From: Michal Hocko <mhocko@kernel.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, keith.busch@intel.com,
	keescook@chromium.org, dave.hansen@linux.intel.com,
	dan.j.williams@intel.com, linux-mm@kvack.org
Subject: Re: + mm-shuffle-default-enable-all-shuffling.patch added to -mm tree
Message-ID: <20190212085428.GP15609@dhcp22.suse.cz>
References: <20190206200254.bcdZQ%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206200254.bcdZQ%akpm@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 06-02-19 12:02:54, Andrew Morton wrote:
> From: Dan Williams <dan.j.williams@intel.com>
> Subject: mm/shuffle: default enable all shuffling
> 
> Per Andrew's request arrange for all memory allocation shuffling code to
> be enabled by default.
> 
> The page_alloc.shuffle command line parameter can still be used to disable
> shuffling at boot, but the kernel will default enable the shuffling if the
> command line option is not specified.
> 
> Link: http://lkml.kernel.org/r/154943713572.3858443.11206307988382889377.stgit@dwillia2-desk3.amr.corp.intel.com
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Keith Busch <keith.busch@intel.com>
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I hope this is mmotm only thing and even then, is this really
something we want for linux-next? There are people doing testing and
potentially performance testing on that tree. Do we want to invalidate
all that work? I can see some argument about a testing coverage but do
we really need it for the change like this? The randomization is quite
simple to review and I assume Dan has given this good testing before
submition.
-- 
Michal Hocko
SUSE Labs

