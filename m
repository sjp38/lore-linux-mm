Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4210C74A52
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 09:27:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5ED3921019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 09:27:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XW74OVag"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5ED3921019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1DFE8E00AE; Thu, 11 Jul 2019 05:27:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECF1B8E0032; Thu, 11 Jul 2019 05:27:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBDC58E00AE; Thu, 11 Jul 2019 05:27:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A4F5B8E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 05:27:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id b18so3289842pgg.8
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 02:27:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=ctjQwgCLlp604HpVeqlyCBpmRi6PoJDKRevkqL/NNWA=;
        b=VVagUk0P3wsUWvIQlDCLNJplOEHZp16QRmaEBpYLjw/tHDShouVYwUju8HAGZViFLf
         2LVUJsIfzSesc7/hdj9RITHmkVJYSdIK0IcGQF77KoCvce03X1Zhhq1RAnZcE/tHD71u
         cFnv/j0m+V/Jq43RQ6j75Q2ul7ESbDZ4hBzBdJOd+j9BZmHUDMt+posdYRYRewGAUskd
         8uMZIYwr1ZDn3uspP+nS1GKxm7gZIfqyVsKQ3POlZmMNJxsc3FGTw0n/z5cf4FfvObC8
         KrJjddd4JZPiROgZh9U4RysUXmgfPO+eeBdvZX2GMkPnpLbpRGC8VjSaeMIbdkzcy+qG
         3dhQ==
X-Gm-Message-State: APjAAAVNQgCvXnJhB6JAtgQE5p7/kxoTvAewOkFW/U519Zh9RIQUiDnK
	IBPCLp6cmTbooLIGrK1SPrivEIhFDUi/C3Z1KPEkR95563jCV1Voylr2X1vd4hDnKfdLyrNOD8S
	WrG67+B9OTuk5jncE7/LnUOdAr/jSjTU78XFzwwL64QVwbZfw1CMZXGosX1aN/PWJ0A==
X-Received: by 2002:a63:6904:: with SMTP id e4mr3292655pgc.321.1562837271629;
        Thu, 11 Jul 2019 02:27:51 -0700 (PDT)
X-Received: by 2002:a63:6904:: with SMTP id e4mr3292599pgc.321.1562837270854;
        Thu, 11 Jul 2019 02:27:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562837270; cv=none;
        d=google.com; s=arc-20160816;
        b=uOoSylwG2BxzQZ4a9KyzH42NCTCXax585CenycqIC7LNeLY+AVeytyjHs4Vu0FAE7S
         +bTjTMVW5VkJ11INay7jdYK9s3VqdVXqSH7akWeioSHTBanwcldsjAl/juihKFJPaaEb
         cvi2phCHVWAZjf2lhGJjd/hrSQ+qyq5DxX080Zfo4Wtwk0O4TKyoKMAXGIMnl+NCzIsT
         4MmUfFzn60dReMjKU2D2L3x95F8uYFiDhmhBjmSXc8CNF5/DgQ95NZAl6YIO2Kg1vQKH
         6K3eMuqjF3ViUkXVzDWYxS7LsyTGpE55pqhNXMgim2lp1gCRBZSU51eGZ3fHUaatgmlH
         rsbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=ctjQwgCLlp604HpVeqlyCBpmRi6PoJDKRevkqL/NNWA=;
        b=ddd+YozH8sCnecKH8SwzS/GU0Q/jLsMT8l8EtdpEpVUSl5hz1fnaFU8KejuUYwmxBe
         xzIQ9cDmqECZK5obzVVcboGJ+Q97dJYUba/qZR3xVwdEIsUTt7dIPAQd/ERFgVaBCgbt
         YpXJskBbjsxhf4k8CyG2B8j2H4cwl/AZ4hSrg3MsMslUmy6R4yUym2mNwpl5jbtFAgCD
         BIffCNldCFESVhg0T2ZtzR2AfEsNYtK8dJuVigcQN3gj9n0tw04PUt3to4Lltd509BVa
         1MCG1BL+PkFQkFqrJd2FykiVI37ml2kH9f0gjYyopXr9y5/bOM8J6CpPLYLe1QymRTn9
         xp8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XW74OVag;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f41sor6327168pjg.15.2019.07.11.02.27.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 02:27:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XW74OVag;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=ctjQwgCLlp604HpVeqlyCBpmRi6PoJDKRevkqL/NNWA=;
        b=XW74OVagqyugV3/wP3THCRvzAueu17tkpao+yo5IHjM8lpQKb6048H3Ny2zPiMlaBe
         eWhLpF+K9KQHEB6wbz91Dz2IO+zyXpsqcPKHP8E66kSa23MHmWz3BI2wuZDY/GlcAlX4
         9gip+KCwm1zKSnAXDjwQ877ARE5KD+Pxzj5PsfoCR+q/o0Svm/zLZOPTOyDxJySzf2+s
         DvfIPszRwZRSYyF/1o5IZqMVya9UQ/720bkO3YthabEBSWqkyw/vwZ9nxtWAWlY632XS
         BKAux4fqS5G4Wz32aM2yJP+pKtMljHicKmK/1r0jMBgrbxwmDP1BpKTgVQhcZmCj0dwO
         R3LQ==
X-Google-Smtp-Source: APXvYqzBE9aU+/1BWb2TunJAkuLc1lAKBCpOQTAA/+hp8NBdlzCDfV9tpMXfluq3s3+NBBp7T2SqaQ==
X-Received: by 2002:a17:90a:3aed:: with SMTP id b100mr3712815pjc.63.1562837270504;
        Thu, 11 Jul 2019 02:27:50 -0700 (PDT)
Received: from localhost (193-116-118-149.tpgi.com.au. [193.116.118.149])
        by smtp.gmail.com with ESMTPSA id q69sm6572107pjb.0.2019.07.11.02.27.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 02:27:49 -0700 (PDT)
Date: Thu, 11 Jul 2019 19:24:52 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH] mm: remove quicklist page table caches
To: Christopher Lameter <cl@linux.com>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org,
	linux-sh@vger.kernel.org
References: <20190711030339.20892-1-npiggin@gmail.com>
	<0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@email.amazonses.com>
In-Reply-To:
	<0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@email.amazonses.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1562835751.mpbmrr7rdc.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Christopher Lameter's on July 11, 2019 5:54 pm:
> On Thu, 11 Jul 2019, Nicholas Piggin wrote:
>=20
>> Remove page table allocator "quicklists". These have been around for a
>> long time, but have not got much traction in the last decade and are
>> only used on ia64 and sh architectures.
>=20
> I also think its good to remove this code. Note sure though if IA64
> may still have a need of it. But then its not clear that the IA64 arch is
> still in use. Is it still maintained?

It should still work (as well as other archs). Does it have any
particular need for page table allocation speed compared to others?

I actually think it's more benefit for ia64 and sh than anything.
For other arches it's no big deal, and generic code just sprinkles
some poorly named function around the place with no real way to
know where it should go or test it. Then not to mention its
interaction with other memory queues.

>> Also it might be better to instead make more general improvements to
>> page allocator if this is still so slow.
>=20
> Well yes many have thought so and made attempts to improve the situation
> which generally have failed. But even the fast path of the page allocator
> seems to bloat more and more. The situation is deteriorating instead of
> getting better and as a result lots of subsystems create their own caches
> to avoid the page allocator.

Yeah, to some degree I agree. And if someone would test it on a modern
CPU and workload that would be cool.

But for example in most workloads you would expect the rate of page
allocation and freeing for processes to be on the same order of=20
magnitude at the low end, up to 2 orders of magnitude higher than
page tables that map them. Not true perhaps for very large shared
mmaps, but all in all IMO it's not clear this is a good tradeoff, or
it's a good idea to proliferate these little queues around the place.

Anyway that's just handwaving from me, but I'm not against the code
being resurrected and added to the more important archs if it shows
good gains on something relevant.

Thanks,
Nick
=

