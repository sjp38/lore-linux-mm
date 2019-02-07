Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06FA2C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:35:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B567C21872
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:35:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="v7wRl+42"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B567C21872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5558E8E003E; Thu,  7 Feb 2019 10:35:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 503888E0002; Thu,  7 Feb 2019 10:35:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F6888E003E; Thu,  7 Feb 2019 10:35:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC61A8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 10:35:11 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id b15so174623pfi.6
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 07:35:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:subject:to:cc:message-id
         :date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=vfrucWasRxu8wXy8I+OWsttiphZ78Pxa89vVhirKE38=;
        b=BjSitMKBUg/iKvu/MjHhZNmM383B/Z48rBlR2fRGXHxCBlXhF/kwoLYcwRvu+z/5aN
         yLYYhcboSn/zJ4ibRinWN8LsY1Pd4g0IQYzQcly6oP0IBtsDlKG5/+JXnKTaB2+WMbSz
         OTLF0406v2bFhPVdeUvpecyzqxqopybDqzhnTDxP2rON4ISn82HkudA8O3h97KEBTeOp
         C8tV0oYDYo/uBxmj1YCyWM+zHdhfyYeNwOSgueEGjcyWau3c4K/umIa8q/CwdHpPiFxN
         U7kpqW3AWCDB7/yN5mMrf1av7SvTJWHCzi1Z/DAMU3YmJQ4I7kfEBHZNF4TWE0GaXZvS
         1WcA==
X-Gm-Message-State: AHQUAuYjiLLOCy0TXPDbcwnUjFbQ+MIU2PKSbKbTZrsi6xIVm+gFM2VA
	AgPIHeg7/RAhu+E/ZgwFhxbqSrafX+0WipKadcVfgIM/Nt1EdNIMsBAImGPgg972i35YxXd++PT
	DoPJEG5hVK12HiLutyxWe9AGxrIjs1iV675+6oyxrNbW3FBBo3kzONbLW3GvYGfvbh/liRYn1M3
	s6LnvT2GPwN+E9MdLTtPAgSELy6OSebipVhghQKPmrltJWdtXJYij/FCTTdOwuT34Yg1E+oXBCv
	GA7p61fPX2Kc/Enwvk5OQX3qSbgsqYZ6JglhD79WcdEWtw/7zHSIQnA32ea9BJReAE4ZaBzzb/Q
	2UA/AWuJTchVnQ5YccBunma1/CmrXNcPAfJDv+sdssQDURWbCEY5X3YJApU9eknCvThQOHh9C9B
	N
X-Received: by 2002:a17:902:7590:: with SMTP id j16mr16400996pll.231.1549553711558;
        Thu, 07 Feb 2019 07:35:11 -0800 (PST)
X-Received: by 2002:a17:902:7590:: with SMTP id j16mr16400916pll.231.1549553710610;
        Thu, 07 Feb 2019 07:35:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549553710; cv=none;
        d=google.com; s=arc-20160816;
        b=J5rPScHJ5W/nCLRVWIRLZQPQz9FqhYQeyee7bIEiAnBZXWFg04Bm8eXo2wbp2AgEkG
         jOH7V8qtFBpCfm3TjdmBL/KfMPwWk6Kday8PXaTphoj1yhpK8URjZ4pxJVlJ1rtYR05Z
         1eGZB/rMTZ2NBROTKLV8DE5lc9k70DAKlseNuPTRjvvgQ7GF7nXLHAflPjjG6L9v3tXi
         LMHDxx20AC2FXvtKVfBZxHrjvgcpJivbHWSGN3fF5gI81Mqhk8Qd5yJrDVeV9RX3XLSv
         Zo/uIFnplHCSlvQnCXvMMn04HQ9m1ocvogZGpn+/8etAe5hQaPdMH4ZglIWO1gaeGigl
         vmoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:cc:to:subject:from:dkim-signature;
        bh=vfrucWasRxu8wXy8I+OWsttiphZ78Pxa89vVhirKE38=;
        b=ESTuXrfcExyM0Vpr1TI/7bdDJm3qTsc98SwYGdd4B9lwmILltrA6Yv4Qf1srJB7VQ7
         5TdW2uTfsLQ+2+jTOfLK2dkDxfoEYctVOl9CWlqC1RA/T9RCw9oGZajsM716tcntZP7U
         WsWrFhjguLmz4HCS7L4Miry0IicZ0VQm80mJquTeOIAuFhPPORJ5C59IWsI5k+ar3fsw
         awjvuAGAumyFvooghoaE9+/bhWazRYbnyMn8GSPiPtRNy3Ijlhk5WmB8oIQNY8cqNG3K
         VyKVEhFx5mEqPG7Cp6IVHCJJQf0LS3lp/54vS9oTxS21iS1GS3zPvrsRbGDLyCW3nq78
         NvAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=v7wRl+42;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r12sor14373234plo.58.2019.02.07.07.35.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 07:35:10 -0800 (PST)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=v7wRl+42;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=from:subject:to:cc:message-id:date:user-agent:mime-version
         :content-language:content-transfer-encoding;
        bh=vfrucWasRxu8wXy8I+OWsttiphZ78Pxa89vVhirKE38=;
        b=v7wRl+42sRdc90Xr3bwo4dY+lG2m08Os2TWzjMUluAmfAXx53mYWdZk9xDGg4xBjPe
         phtFtdx9z2YZiuseCKwB6wNwa2/fqva9NyZ/nXkNtJdZkrPOwVxZqDxmIo7EDYTmH3Qq
         EfZciWgD188NKkDlMzfjm1CPZHfI3m7W3YENaMgUJ9FH2VmtbKk6zehcK6lMjIi8mU50
         03SS12dLlPCftTfVBHVWEfc7hYSNgDG9nxXsw24l4ylQkYFKvZ7/qiNoOuwpy+z58d7u
         U51cvcKmneEnevbHXoLNmee3w5yw8/Cv/Yx5uRByM2pPq3Omm2b0gH8pr4GItIQ84SfK
         aySg==
X-Google-Smtp-Source: AHgI3IaVoMYYKhs8M27q2ZqhI+OfSw6Mv04jJk+GiXW7+JfxddzpCbSEEmMoiRDT4kfCHGPvz5JH/Q==
X-Received: by 2002:a17:902:7c8a:: with SMTP id y10mr16635068pll.71.1549553710158;
        Thu, 07 Feb 2019 07:35:10 -0800 (PST)
Received: from ?IPv6:2600:380:7712:367d:9d7:f8fb:d4f4:2531? ([2600:380:7712:367d:9d7:f8fb:d4f4:2531])
        by smtp.gmail.com with ESMTPSA id s2sm12302582pfa.167.2019.02.07.07.35.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 07:35:09 -0800 (PST)
From: Jens Axboe <axboe@kernel.dk>
Subject: LSF/MM 2019: Call for Proposals (UPDATED!)
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>,
 "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
 IDE/ATA development list <linux-ide@vger.kernel.org>,
 linux-scsi <linux-scsi@vger.kernel.org>,
 "linux-nvme@lists.infradead.org" <linux-nvme@lists.infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
 bpf@vger.kernel.org, ast@kernel.org
Message-ID: <4f5a15c1-4f9e-acae-5094-2f38c8eebd96@kernel.dk>
Date: Thu, 7 Feb 2019 08:35:06 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This is an important UPDATE to the previous LSF/MM announcement:

https://lore.kernel.org/linux-block/51b4b263-a0f2-113d-7bdc-f7960b540929@kernel.dk/

A BPF track will join the annual LSF/MM Summit this year! Please read
the updated description and CFP information below.

It will be held from April 30 - May 2 at the Sheraton Puerto Rico Hotel &
Casino Lodges in San Juan, Puerto Rico.
LSF/MM is an invitation-only technical workshop to map out improvements to
the Linux storage, filesystem, memory management, and bpf subsystems that
will make their way into the mainline kernel within the coming years.

https://events.linuxfoundation.org/events/linux-storage-filesystem-mm-summit-2019/

LSF/MM 2019 will be a three day, stand-alone conference with three
subsystem-specific tracks, cross-track discussions, as well as BoF and
hacking sessions.

On behalf of the committee I am issuing a call for agenda proposals
that are suitable for cross-track discussion as well as technical
subjects for the breakout sessions.

If advance notice is required for visa applications then please point
that out in your proposal or request to attend, and submit the topic
as soon as possible.

1) Proposals for agenda topics should be sent before February 22th,
2019 to:

	lsf-pc@lists.linux-foundation.org

and CC the mailing lists that are relevant for the topic in question:

	FS:	linux-fsdevel@vger.kernel.org
	MM:	linux-mm@kvack.org
	Block:	linux-block@vger.kernel.org
	ATA:	linux-ide@vger.kernel.org
	SCSI:	linux-scsi@vger.kernel.org
	NVMe:	linux-nvme@lists.infradead.org
        BPF:    bpf@vger.kernel.org

Note that we have extended the original deadline by a week, to
accommodate the late arrival of the BPF track.

Please tag your proposal with [LSF/MM TOPIC] to make it easier to
track. In addition, please make sure to start a new thread for each
topic rather than following up to an existing one. Agenda topics and
attendees will be selected by the program committee, but the final
agenda will be formed by consensus of the attendees on the day.

2) Requests to attend the summit for those that are not proposing a
topic should be sent to:

	lsf-pc@lists.linux-foundation.org

Please summarize what expertise you will bring to the meeting, and
what you would like to discuss. Please also tag your email with
[LSF/MM ATTEND] and send it as a new thread so there is less chance of
it getting lost.

We will try to cap attendance at around 25-30 per track to facilitate
discussions although the final numbers will depend on the room sizes
at the venue. Note that BPF track will be limited to 10-15 attendees.

For discussion leaders, slides and visualizations are encouraged to
outline the subject matter and focus the discussions. Please refrain
from lengthy presentations and talks; the sessions are supposed to be
interactive, inclusive discussions.

In particular BPF topics are encouraged to be storage, fs, mm, tracing,
security related or advancing the state of the art of BPF core.
BPF and networking related topics are recommended to be submitted for
Linux Plumbers Conference and corresponding Networking and BPF microconf
later this year.

Thank you on behalf of the program committee:

	Anna Schumaker (Filesystems)
	Josef Bacik (Filesystems)
	Martin K. Petersen (Storage)
	Jens Axboe (Storage)
	Michal Hocko (MM)
	Rik van Riel (MM)
	Johannes Weiner (MM)
        Alexei Starovoitov (BPF)

-- 
Jens Axboe

