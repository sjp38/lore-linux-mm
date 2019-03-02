Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97D67C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 18:46:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5604C20830
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 18:46:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="CUzTz9l1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5604C20830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCA3D8E0003; Sat,  2 Mar 2019 13:46:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D79F78E0001; Sat,  2 Mar 2019 13:46:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C69418E0003; Sat,  2 Mar 2019 13:46:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id A17F88E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 13:46:04 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id k24so1083428ioa.18
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 10:46:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tx4ASGBAzLGHsjmHKiJQSkY9E3fWxtKwk1dKqdKBjR8=;
        b=WPPFnpAvIbLLgiD2t5our7f4K8EFFYEw/t6PkqPHlBtR7SGFWy9OzyDruOpbwlxulS
         hlQOchloQHOo/BvkTCrDNujIU7bzLsVMLQM2bIkKqURgQt4GWoH8g+bRTutQblOOIREd
         mBnPmkp8eYq42z5EN6sdTTj0gd/ZRye1mqeCV7+MCtfcVb+9DBk9I+fB8AUqimJAxUR5
         wgg3NwEWoJUbutLeXdzY7BQ6DQXPfQVHu9zD6LvqBcuY3WUT0J2dwmnQLbiHwEKHf9Dh
         VorSSmHh7a+zsOvt5n6tc5sZuKymU/nLtB/FYz013kU7ANPVFjdeP8t4EjIUrWRsakMh
         k5Cw==
X-Gm-Message-State: APjAAAU0zi76oos+ttHfG7n4SvI3BsVdH9PFX9/HRwe416TicHtmlLK2
	GE1fK5fn4X03fRtDOiNLfSG7UwGWr7WwsPMITnbJzgOmBk0/CXL4mmYujine80X7cnInz2feY1Q
	d4JpYGN4lHoXL14kPyt5Sju2edeyq6ZfZ6Nqz8yUxkRNbvwY67WZ4MYVAC9ZkSNvzkw==
X-Received: by 2002:a5e:9818:: with SMTP id s24mr5693380ioj.219.1551552364434;
        Sat, 02 Mar 2019 10:46:04 -0800 (PST)
X-Google-Smtp-Source: APXvYqzb4DTv9GG60qQNcWZCT8xkg6Kronmr/A4rLzMSBkqX3rwU2brc3rQev8IhNS9Ci5P+o4bd
X-Received: by 2002:a5e:9818:: with SMTP id s24mr5693357ioj.219.1551552363573;
        Sat, 02 Mar 2019 10:46:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551552363; cv=none;
        d=google.com; s=arc-20160816;
        b=swG8ZeudfTMahs6f+bORqIa+VxXiku3wdS9vCen3H1Ve5OXfozFtLMtaUAD6B8tcSc
         ndruQjZGhwIOL7qqC1r+7J7JG6hcjOTga9n8lOFn861zr67N5gdHMsMFH0Ey+kSahKJq
         ETAzo9AlDOo+jsjcqN34HZoCC6PfFq2FXj3xk6Vq1IU9PMxTDOj8jDICT6IceF8HD+sk
         OU6Q1K4IXhdJzYVs+sU09EqOsD5SxFFbwfBpKWHF8zT+vjKP6enQXRPMhCR6gYxlal7Z
         fOKFhvklWRoH39pfiXt2VgVjIi8XfWqfvptb2mC204f3+H2rbV/sJqNIr+7zuLNY/xVr
         NqBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tx4ASGBAzLGHsjmHKiJQSkY9E3fWxtKwk1dKqdKBjR8=;
        b=QE3dElD2d4Zj+ZF792ViQbVSK9m+sHQ2bviiQlHuBb2/KMv7H6p3jSLw0INIb24gGX
         HuOzRlnm6CKm644agcw3xUagzHh5lXZ1Jm9l8ImoenlnvTPuV+rgfZxLDwi0i5/X3yev
         jl9pzRGuZ5ZA/qKGlovhfAxOp55rXLQfW6qXggevCmV2e/FoqvwxBQMbZ0RFDVfJzLhy
         xtmMd30pjpQfIYkhli1OEVPgi+e0zGPxyQi7n4jHLFZntRAT33nxcpjbcaFTQ1NNlVV0
         sq5A6+eTd2s2qmd65ydukYAHuU2DjCclPUJ8mi293t4N2qh2pXx9blAbymPBatKFJA0Q
         ZnJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=CUzTz9l1;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j123si857693itj.70.2019.03.02.10.46.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 02 Mar 2019 10:46:03 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=CUzTz9l1;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=tx4ASGBAzLGHsjmHKiJQSkY9E3fWxtKwk1dKqdKBjR8=; b=CUzTz9l1sHNMNJg65FqQcW45S
	jQAFFCxjQF9ThgJz3A2Qvr2QT45McJuM8YIR0vQeFzNmS/wR11nfAumCVEAHUM4t3OsmTzkCqHF/P
	gtGPY1sPXpEnJQsu4XUwGvBLkiIQv1FN/rnY92a+uZywkBZ+82w0O+PE5gRmwxKLrIYMJP06yJGia
	+4CiKQjyBin8njbFCmMveZcadT33ew7N3UPuy7P0Qwd7SZJERQIo4DdMli0v+Jy+rEv0yrX4DkVOW
	E61kXZopbu9X7CIGf/f0f6RsC9sXhFhwVCjLMC5lIrITnNhlX0nwtgN5Fyvi2kUd52lbXvuSAzp/b
	njtINShxQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=worktop.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h09do-0001Yd-RN; Sat, 02 Mar 2019 18:45:45 +0000
Received: by worktop.programming.kicks-ass.net (Postfix, from userid 1000)
	id 5ED0E984351; Sat,  2 Mar 2019 19:45:44 +0100 (CET)
Date: Sat, 2 Mar 2019 19:45:44 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org,
	riel@surriel.com, mhocko@suse.com, ying.huang@intel.com,
	jrdr.linux@gmail.com, jglisse@redhat.com,
	aneesh.kumar@linux.ibm.com, david@redhat.com, aarcange@redhat.com,
	raquini@redhat.com, rientjes@google.com, kirill@shutemov.name,
	mgorman@techsingularity.net, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm/memory.c: do_fault: avoid usage of stale
 vm_area_struct
Message-ID: <20190302184544.GM14054@worktop.programming.kicks-ass.net>
References: <20190302171043.GP11592@bombadil.infradead.org>
 <a5234d11b8cc158352a2f97fc33aa9ad90bb287b.1551550112.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a5234d11b8cc158352a2f97fc33aa9ad90bb287b.1551550112.git.jstancek@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 02, 2019 at 07:19:39PM +0100, Jan Stancek wrote:
>  static vm_fault_t do_fault(struct vm_fault *vmf)
>  {
>  	struct vm_area_struct *vma = vmf->vma;
> +	struct mm_struct *vm_mm = READ_ONCE(vma->vm_mm);

Would this not need a corresponding WRITE_ONCE() in vma_init() ?

