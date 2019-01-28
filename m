Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99393C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 14:45:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E90E2147A
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 14:45:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E90E2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED8578E0009; Mon, 28 Jan 2019 09:45:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E877D8E0001; Mon, 28 Jan 2019 09:45:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D774E8E0009; Mon, 28 Jan 2019 09:45:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5B68E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:45:16 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i55so6720091ede.14
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:45:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=VmmjCE9nv23gtn5FhnfCZit8Inds2NxcQgpLgdIXFWA=;
        b=m1X7ouY0Lv7qSfcijK0XOlrByLNl+9ssBtfY6EbPhsukW2MqOP5A5tH9rfk3OOLF7G
         LXwOceWzd9Hj7bZLzL0QW6hMjJg/jblc+Ikkr01/f4nZbStbwD3NCA//1a6KJDAGj9L5
         zRkVfoZzIjIWjQ3Wm4cFznG0kV3eq0wbusbrTgdcE6jQkEhjy2Jc8mnxLXwdvrhWje0J
         WiRXMW6U2LiZNLzxqaCbSth+dp7VaB3F9OaN6qcIRLIqI6k+1qFsjkvyMNM2UXuNvesL
         v7bKFfysIB6eHXw8kbp8EOCTRZJVa3FRgczuJQ1a7uiS+TkTFSk8Z+IBcD91nyw4dr4Y
         IGWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukeqT+WgIHMg8yWsUMoZFGeYqvCKx4vTCMGehOndEDpEyVJcthQF
	3pcW5VYjzaSb07Kr3Dtm0vemZCfnXTJgcnjvrbFFPH4IjnTWCTiwBUVbWgkA88QKHaL5JkYrCQd
	ZexEv5/in1XASpk8aUEW5zCRt/aDXOAA/3+EpYDPonT2nT7s2uOEjXQM2jCpFUza04YYlWuT2nD
	elDdVIsOpHHSsz/6mMgBTrG52LH41AOHu2TMRkhr+UkbX8QGZxXqMWycrIR7oQfAHyE4UY9r9va
	eVS5MRHiqIrAMNu4oDI6s7SnBFRUby5oetmIOqP0uoaWcjumjjUiIldABe27LEnw4z4yzIoFYVu
	oAOeT+pwzXVseaygqzSAEAhIovKhdJi33a1StMDWBhlcsQar9HV/6ArY8S8sa6Tm6yxab/UG8A=
	=
X-Received: by 2002:a50:b623:: with SMTP id b32mr21314443ede.55.1548686715932;
        Mon, 28 Jan 2019 06:45:15 -0800 (PST)
X-Received: by 2002:a50:b623:: with SMTP id b32mr21314387ede.55.1548686714951;
        Mon, 28 Jan 2019 06:45:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548686714; cv=none;
        d=google.com; s=arc-20160816;
        b=j33wy4jzSsxPa1kfweZXtRiaBerXRyagNCqkoyzUWL1huUHUT19E7so+/bp/cupjNF
         aE4MyRN8u65tVYewIhfJHd5Ck6RAYSHtN11qD7tLNzWz4d061Cc2kO9JYjLNh4T7xrRS
         0owZh2WaGpIDdWzmoOHkPXsijsHKEFfw9GHk6ei+hUR1Y6xUYoaRrmUObB30Hp6kKik+
         uxZhznPqYhai8NXMx//QAffnI/XiRSGD6E8IJifqfeGn5qqsJhhR8Jxgba5jU0gY5vgY
         Nz/MUADmq+mahtgs/uf7lmmKNItFFvdZ10GfFhJ+6bqP7OCNeO1LunJbI4VcItgv17zO
         2INw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=VmmjCE9nv23gtn5FhnfCZit8Inds2NxcQgpLgdIXFWA=;
        b=zFxscVSope7MHHkVBSL45IujLFvVwlLZi1tJXTMk0/H4DNjugEafofQ1x2X2OnFQyy
         YnpfgufFBVGBvQJrYkhUod4RYBY2ed8r/BIRbmwLApsRjIAB9CpkMowkw8gsp4lDVP2U
         9BK3QPuasxOzwxtwfDxFiw4IYpoO4ug25BWCKuH/OpffUVymoWPGr+WWpT62HnY61Bae
         cgEc2cyADqv+cqmng9DZ9fWcopM020zIldTbW9ncjax6QRDGeE/2UFEUFmhtpxSHfC2U
         BU5Kn7ZTNbNesULmj9Y+z3TMi3NsKak8gQhNh5Jh6ZDHiiCmHqiruJT7HokNuORRXjIz
         +Ltw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k26sor29807334edd.12.2019.01.28.06.45.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 06:45:14 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN4zQOz65VeZcD/EvoZAlxOuVydw3aMLYl71U5hV9bAJy37VDh3kDv/DMgsa1BCH1aA2Xxwr4w==
X-Received: by 2002:a50:b205:: with SMTP id o5mr21305494edd.245.1548686714588;
        Mon, 28 Jan 2019 06:45:14 -0800 (PST)
Received: from tiehlicka.microfocus.com (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id j8sm2919064ejr.17.2019.01.28.06.45.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 06:45:13 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com,
	gerald.schaefer@de.ibm.com,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH 0/2] mm, memory_hotplug: fix uninitialized pages fallouts.
Date: Mon, 28 Jan 2019 15:45:04 +0100
Message-Id: <20190128144506.15603-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190128144504.HSsPhVgCd8uzSWjRIFNcqTkZTrO1tUx_GpMmL3clqkI@z>

Hi,
Mikhail has posted fixes for the two bugs quite some time ago [1]. I
have pushed back on those fixes because I believed that it is much
better to plug the problem at the initialization time rather than play
whack-a-mole all over the hotplug code and find all the places which
expect the full memory section to be initialized. We have ended up with
2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full
memory section") merged and cause a regression [2][3]. The reason is
that there might be memory layouts when two NUMA nodes share the same
memory section so the merged fix is simply incorrect.

In order to plug this hole we really have to be zone range aware in
those handlers. I have split up the original patch into two. One is
unchanged (patch 2) and I took a different approach for `removable'
crash. It would be great if Mikhail could test it still works for his
memory layout.

[1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
[2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
[3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz


