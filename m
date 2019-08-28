Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2814EC3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 17:19:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8AB820679
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 17:19:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8AB820679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D14B6B000D; Wed, 28 Aug 2019 13:19:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 181E96B000E; Wed, 28 Aug 2019 13:19:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 070526B0010; Wed, 28 Aug 2019 13:19:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0254.hostedemail.com [216.40.44.254])
	by kanga.kvack.org (Postfix) with ESMTP id D9DDA6B000D
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 13:19:30 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 7DA4F180AD7C1
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 17:19:30 +0000 (UTC)
X-FDA: 75872498100.06.point58_70128eddc6954
X-HE-Tag: point58_70128eddc6954
X-Filterd-Recvd-Size: 3171
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 17:19:30 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BB35A807064;
	Wed, 28 Aug 2019 17:19:28 +0000 (UTC)
Received: from treble (ovpn-121-55.rdu2.redhat.com [10.10.121.55])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5FB1360BEC;
	Wed, 28 Aug 2019 17:19:26 +0000 (UTC)
Date: Wed, 28 Aug 2019 12:19:23 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, broonie@kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
	mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
	Peter Zijlstra <peterz@infradead.org>
Subject: Re: mmotm 2019-08-27-20-39 uploaded (objtool: xen)
Message-ID: <20190828171923.4sir3sxwsnc2pvjy@treble>
References: <20190828034012.sBvm81sYK%akpm@linux-foundation.org>
 <8b09d93a-bc42-bd8e-29ee-cd37765f4899@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <8b09d93a-bc42-bd8e-29ee-cd37765f4899@infradead.org>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.67]); Wed, 28 Aug 2019 17:19:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 09:58:37AM -0700, Randy Dunlap wrote:
> On 8/27/19 8:40 PM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2019-08-27-20-39 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> > 
> > You will need quilt to apply these patches to the latest Linus release (5.x
> > or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> > http://ozlabs.org/~akpm/mmotm/series
> > 
> > The file broken-out.tar.gz contains two datestamp files: .DATE and
> > .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> > followed by the base kernel version against which this patch series is to
> > be applied.
> 
> 
> 
> drivers/xen/gntdev.o: warning: objtool: gntdev_copy()+0x229: call to __ubsan_handle_out_of_bounds() with UACCESS enabled

Easy one :-)

diff --git a/tools/objtool/check.c b/tools/objtool/check.c
index 0c8e17f946cd..6a935ab93149 100644
--- a/tools/objtool/check.c
+++ b/tools/objtool/check.c
@@ -483,6 +483,7 @@ static const char *uaccess_safe_builtin[] = {
 	"ubsan_type_mismatch_common",
 	"__ubsan_handle_type_mismatch",
 	"__ubsan_handle_type_mismatch_v1",
+	"__ubsan_handle_out_of_bounds",
 	/* misc */
 	"csum_partial_copy_generic",
 	"__memcpy_mcsafe",

