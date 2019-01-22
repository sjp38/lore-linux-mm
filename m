Return-Path: <SRS0=7n0b=P6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C0E9C282C3
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 08:52:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16C232084C
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 08:52:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16C232084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A63778E0003; Tue, 22 Jan 2019 03:52:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EA678E0001; Tue, 22 Jan 2019 03:52:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88CD18E0003; Tue, 22 Jan 2019 03:52:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52EFA8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 03:52:38 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a23so17876005pfo.2
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 00:52:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:to:cc:subject:references:in-reply-to:mime-version
         :content-transfer-encoding:content-disposition;
        bh=ppLteORMlUtf/fi5TYtZzK4LVAiuFz2UaSAY2hsYxUk=;
        b=l19WwcV8erZ/09wJzMGG+3Wta0aTU1SutGQlkDDsVVmBnuzWaaKQvpka8u5EvdOD0a
         wKkVn+3mSk6B+d2ILlFDcpZ4QB9/4knLPCsldBJVkMgVBNQ0zX3gizIVcU6HZbGbrQxq
         NtGK/I59wfIQlXBCca1hAvu90JY62gg2Z5o4bYVCU+lFbk5uXbmxMvY99S0tomUIqLqD
         LFeXOfX+QZZYb0tuVv1R9RsWivW/LpldKLYfv2xnc+d01uzorvNNAcIeamOwI7LdLvwE
         tLITiCGD5wy7EdP0ZiHBE51hjGKVOADZeSyxa5/eMeDbOuepZ8j/75JIFbA5L5mB4eAf
         mylg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jbeulich@suse.com designates 137.65.248.33 as permitted sender) smtp.mailfrom=JBeulich@suse.com
X-Gm-Message-State: AJcUukeXpBk1SeOXdPoncRVYUn7e/9LM8nod0tugdey5B2jrBk4U2R/Z
	FKrhj4yHiac6n8WupuTuvVovunuTgmc1WMaC1Y4VyPTLYtxNLNSvQHzO0pdpr1yXrL6AqhR+Xwb
	7K+vTAYX6O5qJK15BMYViebYhUFSvTnA3qJGTE0g04aiPxUsgOXIc1XL8UdmVDMRDgw==
X-Received: by 2002:a62:a510:: with SMTP id v16mr32534042pfm.18.1548147157961;
        Tue, 22 Jan 2019 00:52:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN595o21y+WSFVPuQ7Xu5aZcBorOxAaY8de0hptwwZeJRyP9Ko63bQyvLfNAb5hW5J/q/OVE
X-Received: by 2002:a62:a510:: with SMTP id v16mr32534014pfm.18.1548147157168;
        Tue, 22 Jan 2019 00:52:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548147157; cv=none;
        d=google.com; s=arc-20160816;
        b=d3bnRSXLGDav28/H+5wMcVpFqRsEq8VCUEzbXVZRyCDtwGcRxLTg2aD6skuWbTHOq/
         E3Sz5ommDX5oJ4QqX1g1xbV2ucDKmf9RXTqQ6bGFaJ7sM9SxVcH3+asq0GkqAmw11duz
         x9+3WWQGqAnmrGY28bd/GNJjiVB6Lbe/gjEvlrrShKf3xe2hk8BDF9seLA8pIuliFjzt
         3NFVhRlT2Rg4yhCflIXylGuvDX7o65lClgXPLF7hcFb4RPUxqdjX2i75xYFCJDYMZyfi
         SnzbQS6FLJQbDQOwAvTTuC9n8/V7xQ6AqHiPU86JoLCiT8V/e0VC8tOfhH0LXjpbPuL5
         5ckg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:content-transfer-encoding:mime-version
         :in-reply-to:references:subject:cc:to:from:date:message-id;
        bh=ppLteORMlUtf/fi5TYtZzK4LVAiuFz2UaSAY2hsYxUk=;
        b=gDFU8EJH3kQP5XYRh8yus3EU3I92TjF7Wq/ozsuC5sZwypVnfOKUjMCYxAUOygNiGH
         XdfHCcRoP2XH6tTWJzBFegkdGqQDHvsAMJDFSK+1Bn0GPLK1mIIOYK7N4z69ZGo9Ow4e
         KZoOgAeOkBvVAnkctbGYArgbu2ewO8AyTP2d+3Esl7XJ1OFhDrbXgNFAvOp4yKxkZinj
         UMxFyt4CEW+ilE65wNPxWniSHCnYG3se6gavs10f37BpatFJIpvcFjbpEgOZTzBqKED3
         0CkV2+t5rJ0iytN2HVG8mIb1xqEC+E9Zj2pLeYKtArvYgfkOlLMAq2TkYZJrLkxGq1mA
         ikdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jbeulich@suse.com designates 137.65.248.33 as permitted sender) smtp.mailfrom=JBeulich@suse.com
Received: from prv1-mh.provo.novell.com (prv1-mh.provo.novell.com. [137.65.248.33])
        by mx.google.com with ESMTPS id q2si16021899plh.261.2019.01.22.00.52.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 00:52:37 -0800 (PST)
Received-SPF: pass (google.com: domain of jbeulich@suse.com designates 137.65.248.33 as permitted sender) client-ip=137.65.248.33;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jbeulich@suse.com designates 137.65.248.33 as permitted sender) smtp.mailfrom=JBeulich@suse.com
Received: from INET-PRV1-MTA by prv1-mh.provo.novell.com
	with Novell_GroupWise; Tue, 22 Jan 2019 01:52:36 -0700
Message-Id: <5C46D9D00200007800210007@prv1-mh.provo.novell.com>
X-Mailer: Novell GroupWise Internet Agent 18.1.0 
Date: Tue, 22 Jan 2019 01:52:32 -0700
From: "Jan Beulich" <JBeulich@suse.com>
To: "Juergen Gross" <jgross@suse.com>
Cc: "Borislav Petkov" <bp@alien8.de>,
 "Stefano Stabellini" <sstabellini@kernel.org>,
 "the arch/x86 maintainers" <x86@kernel.org>,<linux-mm@kvack.org>,
 <tglx@linutronix.de>, "xen-devel" <xen-devel@lists.xenproject.org>,
 "Boris Ostrovsky" <boris.ostrovsky@oracle.com>, <mingo@redhat.com>,
 <linux-kernel@vger.kernel.org>, <hpa@zytor.com>
Subject: Re: [Xen-devel] [PATCH 2/2] x86/xen: dont add memory above max
 allowed allocation
References: <20190122080628.7238-1-jgross@suse.com>
 <20190122080628.7238-3-jgross@suse.com>
In-Reply-To: <20190122080628.7238-3-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190122085232.3EbMoT2d_s-8RR8mXewYIu5TmMdUTdb7D9T3Rd7dW4Q@z>

>>> On 22.01.19 at 09:06, <jgross@suse.com> wrote:
> Don't allow memory to be added above the allowed maximum allocation
> limit set by Xen.

This reads as if the hypervisor was imposing a limit here, but looking at
xen_get_max_pages(), xen_foreach_remap_area(), and
xen_count_remap_pages() I take it that it's a restriction enforced by
the Xen subsystem in Linux. Furthermore from the cover letter I imply
that the observed issue was on a Dom0, yet xen_get_max_pages()'s
use of XENMEM_maximum_reservation wouldn't impose any limit there
at all (without use of the hypervisor option "dom0_mem=3Dmax:..."),
would it?

Jan


