Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CA14C4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 23:37:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAF9B206C2
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 23:37:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAF9B206C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F4786B026A; Tue, 17 Sep 2019 19:37:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CB126B026B; Tue, 17 Sep 2019 19:37:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E1BF6B026C; Tue, 17 Sep 2019 19:37:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0149.hostedemail.com [216.40.44.149])
	by kanga.kvack.org (Postfix) with ESMTP id 5EF046B026A
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 19:37:41 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E245F909B
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 23:37:40 +0000 (UTC)
X-FDA: 75946027080.14.loaf63_430273977ed06
X-HE-Tag: loaf63_430273977ed06
X-Filterd-Recvd-Size: 1284
Received: from mail.test.com (pc-246-229-214-201.cm.vtr.net [201.214.229.246])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 23:37:40 +0000 (UTC)
Received: by mail.test.com (Postfix, from userid 1001)
	id C625E127B; Tue, 17 Sep 2019 18:37:38 -0500 (CDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.test.com (Postfix) with ESMTP id C1DB1E32;
	Tue, 17 Sep 2019 18:37:38 -0500 (CDT)
Date: Tue, 17 Sep 2019 18:37:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
X-X-Sender: cl@lameter.cl
To: David Rientjes <rientjes@google.com>
cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, penberg@kernel.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slub: fix -Wunused-function compiler warnings
In-Reply-To: <alpine.DEB.2.21.1909171423000.168624@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.21.1909171837250.9981@lameter.cl>
References: <1568752232-5094-1-git-send-email-cai@lca.pw> <alpine.DEB.2.21.1909171423000.168624@chino.kir.corp.google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.220403, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Sep 2019, David Rientjes wrote:

> Acked-by: David Rientjes <rientjes@google.com>

Ditto


