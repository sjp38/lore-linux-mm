Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCE7AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:21:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6384221874
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:21:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="rEGlF8lr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6384221874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE3966B0005; Thu, 21 Mar 2019 09:21:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6C8E6B0006; Thu, 21 Mar 2019 09:21:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 934EE6B0007; Thu, 21 Mar 2019 09:21:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1D26B0005
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 09:21:30 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k29so24013891qkl.14
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 06:21:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=2sRlF6ZPMsm6mlH3SyYKbLJsFAmGUPzgj87yHVKkBJE=;
        b=lzc/AD/RNGlVwGBeQnwb6/XJhYeYoUkLDsRmbXTr7sl/ZgLBnd2bwE/Ea8t7mtvaoH
         5BHeYVgqE52kHOru5+Q5f5fO+bTfhmKBEMl9kBLX/nmgj/cGO2s9ipou0o3uZ2um52ki
         6+KnF9pS4fDZ2Hvs//BxGs5nUAq7UYGfNymLFk9Yy1QqA1WodtLJ6I/NGYGxxIonF4n4
         2S5tunadY4icmUnZcpbSEZGJcKI+xc4f0N7eIfm+csfVLAiS+gfwrpG4KnFUTDcPLW+d
         iSRuOqDyfm2mBOmLrbbzjFJ6mBDekDupMSC0QjfMntrrZDVZVqauGjWWXCXXZ7hV/jKm
         ELkg==
X-Gm-Message-State: APjAAAXTCxItBEtQ1uZpxwEWaTv+cZqURo2rSM6xDNWWdCuGmcR40zFp
	ugObBip2gbouM/TQ+kv0hRHQ4ixFlR0U+fkMbNK9p/a6LpaedwvzgMDkKaOf8KQ/sayz/umt6Oa
	6DGj/Cyf6m/gwGfQwTv8R1EtZrzOxWLqoArexsu8qdeWwxbkeRDiktpQMqLJzPSuVvw==
X-Received: by 2002:ac8:2c93:: with SMTP id 19mr3024451qtw.126.1553174490136;
        Thu, 21 Mar 2019 06:21:30 -0700 (PDT)
X-Received: by 2002:ac8:2c93:: with SMTP id 19mr3024385qtw.126.1553174489261;
        Thu, 21 Mar 2019 06:21:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553174489; cv=none;
        d=google.com; s=arc-20160816;
        b=m0uJxwED5x1THogVT0O5QttXnJ/oG+FwDBNF2WEF/kQd66Gkfgbms/ervWcZWa7/gH
         h3gQvdPlw9S3Z7u0W91kvjah1NSGndJ3QEY6q/dOqmc5pcZBd7Lo0aVfPqGiicHgp+Yk
         bI6BQnys+zRtEcel5Lr2M/d6M9NyDsNEJ0fpt6afEA0hyEg79V01MHOHXiC/OVcxg5aA
         Ik6qxgdzQGJ5j8raXw+9cyuXa24c3q/EgfKTK9yLj35fwaYxtDkL+RmFVh83vf+9zYnw
         UvtNHDaZJMPj6mKeFU5vhVKwZAMIwzhIHJCYUspoNytwmCu33z7H/GpvTu1GusFfB5vb
         du7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=2sRlF6ZPMsm6mlH3SyYKbLJsFAmGUPzgj87yHVKkBJE=;
        b=0E/siitsDqaq0nPTBhlXDIQig68y4YK1YdYicf9902IpSdwjF3eSxMmPZFtXtLuf59
         SzVIsfU5EVJoqgzV/w22GtzlviFXc3jSsBHd+ZqvRcb/H2v083dQ9D8Qjq6eveYoOS5V
         m/eWByz5ApPQ+wO68sCjAgbLGFi6nBQA5W+SyS69G4jfPiGPG/BEC9bHNloEQ/sK65Vy
         MedM2OlWdCG1Rhq5iJJWVVNknUpzO7S/opK3W0Y7I5+F4NPzrV88wHW15X4vnCFI/UN1
         upnFFInwadjcyveYFkQzUO81j01UxeR6DAFKqMupqNxGp110Kn/kEcYQIIqojD1faJqY
         lduA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=rEGlF8lr;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m27sor8412012qtk.2.2019.03.21.06.21.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Mar 2019 06:21:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=rEGlF8lr;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=2sRlF6ZPMsm6mlH3SyYKbLJsFAmGUPzgj87yHVKkBJE=;
        b=rEGlF8lrG5HqX3yX1DTNKR69zr2GawNrFm3aYBy8bEJnzWW6lxkbPaJWJrt9AKIS2V
         R+5vaQZBarCb2ASFMcGgrOLgQ9rdTbA8JXLoI4/FdAPEyCsMZa+5P9Rer2k08B1Srf7E
         7+m18/PHjR+A1ACI89mJqYQ9hXqArKOL41AFyQjGAv8uxOgp4hz9bBbd5oPFBpw0S0ZU
         HDaGoNwyOcg9LDh2pnG482b9N+8xUP0Q8Y5UR/9ij7kEF6L3XqzXBasP1TfSOpw1khGU
         zqWO+pfohcORoDzi/jZ6CFDoY3FGNLRjsf3a3ysSNTkHvKz+14v+xS6HiIq9Y3yjRPjV
         UQgg==
X-Google-Smtp-Source: APXvYqw6fbobgFnc+kP80d7EIvSxcwbdbh3hQoQe2J7dzu4OPz1o/ishR2VqtQYTH611jDldga5/ag==
X-Received: by 2002:aed:3829:: with SMTP id j38mr2853374qte.385.1553174488965;
        Thu, 21 Mar 2019 06:21:28 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id n1sm3129601qkd.28.2019.03.21.06.21.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 06:21:28 -0700 (PDT)
Message-ID: <1553174486.26196.11.camel@lca.pw>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
From: Qian Cai <cai@lca.pw>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, Daniel Jordan
	 <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, mgorman@techsingularity.net, vbabka@suse.cz
Date: Thu, 21 Mar 2019 09:21:26 -0400
In-Reply-To: <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
References: 
	<CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
	 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
	 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
	 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-03-21 at 10:39 +0500, Mikhail Gavrilov wrote:
> I am right now tested the patch [1] and can said that unfortunately it
> not fix my issue.
> [1] https://patchwork.kernel.org/patch/10862519/
> 
> I am attached full kernel log here.
> 
> How issue reproduced:
> 1) Application with heavy I/O activity eat memory for disk cache. (For
> example steam client downloads heavy game 50Gb)
> 2) And when starts using swap this kernel panic is happened.
> 
> My system specs:
> RAM: 32GB
> Swap: 64GB

Does it come up with this page address every time?

page:ffffcf49607ce000

