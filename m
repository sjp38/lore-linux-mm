From: David Rientjes via Linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Subject: (unknown)
Date: Thu, 28 Jan 2016 09:22:17 +1100 (AEDT)
Message-ID: <mailman.767.1453933115.12304.linuxppc-dev@lists.ozlabs.org>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com>
 <1453889401-43496-4-git-send-email-borntraeger@de.ibm.com>
Reply-To: David Rientjes <rientjes@google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7973320260964271912=="
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1453889401-43496-4-git-send-email-borntraeger@de.ibm.com>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, davej@codemonkey.org.uk, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net
List-Id: linux-mm.kvack.org

--===============7973320260964271912==
Content-Type: message/rfc822
Content-Disposition: inline

Return-Path: <rientjes@google.com>
X-Original-To: linuxppc-dev@lists.ozlabs.org
Delivered-To: linuxppc-dev@lists.ozlabs.org
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [IPv6:2607:f8b0:400e:c03::236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by lists.ozlabs.org (Postfix) with ESMTPS id 150141A1A0E
	for <linuxppc-dev@lists.ozlabs.org>; Thu, 28 Jan 2016 09:18:33 +1100 (AEDT)
Authentication-Results: lists.ozlabs.org;
	dkim=pass (2048-bit key; unprotected) header.d=google.com header.i=@google.com header.b=hPk0dCJH;
	dkim-atps=neutral
Received: by mail-pa0-x236.google.com with SMTP id uo6so11673284pac.1
        for <linuxppc-dev@lists.ozlabs.org>; Wed, 27 Jan 2016 14:18:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20120113;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version:content-type;
        bh=coCzZSx0uD9RYqGgKzXG8lohQh/Jpq0jGOAYuF1Ygp0=;
        b=hPk0dCJHs1z+BRxM3K4lwNV3rBnoMgDxvNfXROR/BYbQdN3FQmMk0XlMFS4xAiLsz0
         WruGBwJWgexQbIhbqK2p83g3m7JyMpinKXluh+qKRGaPzF03RlCmoBtDRHTKrU9So4Lo
         PBDxgFDpaDslHf6gK0apTVbAAF9JVOPAB5uu7CcJQCyV6DGe09L6qBzgXzkq7pdAqxdt
         PF5HCi4RIw8ccz3p0yuf4oBi+bVYWR3zEWx6MrGS3aAzecxxICb364IrQY7LFYsDxPG3
         P9qN1NZ/aFcOamO0iOdIBlmN0fcOC4HBOQ7FE3N+RLVz9JPl02Rj53GwrlWfDz9b+jX4
         WigA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20130820;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version:content-type;
        bh=coCzZSx0uD9RYqGgKzXG8lohQh/Jpq0jGOAYuF1Ygp0=;
        b=k8dF5NzidAy0JBjY/3dVwkmzPD6I3i2NhnmmsMU6HqeAvrgxObg6Mklsi887QUWoe8
         J4NdvElR0mZLCpuEI1jkRMOnjdoTr9VbUhSQQsJrEBV1CT7TFpmtPLQjbpEKase1gDtT
         z3L8WQJwYMgChzAu68g0V95SvTTgWXf+7vPL3jKnn9+mejrjQTzwkaos9t4nAMI+Otuq
         nL3pTyrNziAEdR4wsoEhexSnPsK+LffUFAA+6I66zGD5bYQleqWtutjWwvB4Dr3wkHuu
         fjGdew2JmkdIrtKp6Nk3RNcECfqNF8ToOezovh5dKDDKozAST3z3ej8a99Zp8OtqqHAD
         IQWA==
X-Gm-Message-State: AG10YOS8dGMc4dY2U2IXFYLrMxq0MXyr77XBsexH6VxfEL5g2o5siC04OvulRUTVuHBY0L/K
X-Received: by 10.67.3.134 with SMTP id bw6mr8779507pad.154.1453933110949;
        Wed, 27 Jan 2016 14:18:30 -0800 (PST)
Received: from [2620:0:1008:1200:77:27bb:147d:6cc2] ([2620:0:1008:1200:77:27bb:147d:6cc2])
        by smtp.gmail.com with ESMTPSA id 20sm11315786pfa.5.2016.01.27.14.18.30
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 14:18:30 -0800 (PST)
Date: Wed, 27 Jan 2016 14:18:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Christian Borntraeger <borntraeger@de.ibm.com>
cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
    linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
    x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk
Subject: Re: [PATCH v3 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <1453889401-43496-4-git-send-email-borntraeger@de.ibm.com>
Message-ID: <alpine.DEB.2.10.1601271418190.23510@chino.kir.corp.google.com>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com> <1453889401-43496-4-git-send-email-borntraeger@de.ibm.com>
User-Agent: Alpine 2.10 (DEB 1266 2009-07-14)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Wed, 27 Jan 2016, Christian Borntraeger wrote:

> We can use debug_pagealloc_enabled() to check if we can map
> the identity mapping with 1MB/2GB pages as well as to print
> the current setting in dump_stack.
> 
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Reviewed-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--===============7973320260964271912==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============7973320260964271912==--
