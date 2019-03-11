Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B9EDC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:06:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43C16214AE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:06:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43C16214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6EF68E0003; Mon, 11 Mar 2019 19:06:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1D898E0002; Mon, 11 Mar 2019 19:06:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE68D8E0003; Mon, 11 Mar 2019 19:06:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF6D8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:06:56 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id m2so213879wrs.23
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:06:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=d23nwJuZ+7mvm1SmED2Yej20dxvfmWvNpfAsAKDwWic=;
        b=IV/WW0nusUdp4WTVytZbrUN94XhoUj03dFOKbSq1kQqeVgeh6S0tz5S6WvdAmQvno9
         oIRr0T+GBXU0/n8v4IW+ntaBwnVLUAwUjSYqXmqSF+i4swx2JgNgu6CIGs1jqvQhW3Gi
         YIxmsBi2fjscSG/e9VqhP0DTH2Rxe81mgTdEm8bulAETgnkAnYzWJFS5pqPuOEjtTbv4
         EZn3c88hGZqDezsbhjOnbagfKkmREzrCrozI5S8MXqU6W7EpRaQHxmHwzkzgXuxE2BCV
         pEupoSgwgwnWCybLFcuUlx7s2iZivYXaDmOWpVpVCuoufyt/HqaG0oEsM84o3vC3G1W0
         HvFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: APjAAAVif2gmA0nqk7acwfmKMTXeR96MMPZOG4JaGeMUQdVV5w6xQaaO
	FLXA/Ix2y5SciVALFz0Ik7NrDdDRslb+SDLCHJiumCj+fR+r4CygEfJA88f7/ohSV1AR/LrlT7i
	nw4JfXqtswYoxAf0DQpQbBfUVyoulztLSiyQx2b1JPORF8xAU6uckkA4Q4IAW681Tyg==
X-Received: by 2002:adf:dfca:: with SMTP id q10mr22213010wrn.45.1552345615976;
        Mon, 11 Mar 2019 16:06:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKkTkySky49p9T12rK/s7o3nJQUCpACm+HCbeFez8JkqBG7mBors/p2JTRN1sGdKUWXtf6
X-Received: by 2002:adf:dfca:: with SMTP id q10mr22212990wrn.45.1552345615245;
        Mon, 11 Mar 2019 16:06:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552345615; cv=none;
        d=google.com; s=arc-20160816;
        b=D25IBgr6jtRkMf4Wu9hzgJrqeWk8Pqvxy6eMtXOJf5V7X87M1qJK+dnvHj6EeAcC2V
         W0ZiKdTjW+iZLHM9ZzhkhuHnG56u6d1v89nruAU8VM05LUyE5jvrmul+DTpPihrzpF0g
         VhMW63Ud82Ux1UK/anfDj8PJwqf7kq4tFqKebyN/dtUFAqtnbGP8UXAbBpNQTE3k8I8S
         EhRNygVg6i5mBa+JLsiWnNzzoUt+19XswDrlAgjQX5MAJ5vLt09uaXLf1IX7+szC9uYl
         kWIkP2Cba+jLqbJ1jqkN9Xu00ZsCr/oWY3VF09cmJA0e+UGdWy9X8qxCdt7RwwyPVD+1
         +hxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=d23nwJuZ+7mvm1SmED2Yej20dxvfmWvNpfAsAKDwWic=;
        b=c05HA+cVZec1T9uOcUvksFe1bnje0z3eCndrxdNIdnWvp/nDc1WDr9jJuzmq/ttIfk
         KanlaDr+kXHmktpuHeIEq/hFM4RIKewR+raIFNuW8Y/anauIwVqGMdTfaTjxQsWNdCWt
         S8Xq7/X6sEadVNSeFEcr6tXTtRqxixMTOVAyBGb3QFVHx13e6/mOSfRsE6zSbbt16LWO
         WhmzhFxDiHWvT77EKERzgvgS4pQNS4AW0/IaEFD9uqL8hEAYz9XJgfdsCJW6D/Rj/C4J
         5cyUdEqVgKf6ixiWM+IwtixlcEEodVtdumlhuXqSH+lqJbv3feY9tUcRHwAMOpjhvtVY
         +AXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id s12si305263wmj.154.2019.03.11.16.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 16:06:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) client-ip=192.134.164.83;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.58,468,1544482800"; 
   d="scan'208";a="372922444"
Received: from 91-160-5-165.subs.proxad.net (HELO [192.168.44.23]) ([91.160.5.165])
  by mail2-relais-roc.national.inria.fr with ESMTP/TLS/AES128-SHA; 12 Mar 2019 00:06:54 +0100
Subject: Re: [PATCHv8 00/10] Heterogenous memory node attributes
To: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org,
 linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Dan Williams <dan.j.williams@intel.com>,
 Jonathan Cameron <jonathan.cameron@huawei.com>
References: <20190311205606.11228-1-keith.busch@intel.com>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 mQINBFNg91oBEADMfOyfz9iilNPe1Yy3pheXLf5O/Vpr+gFJoXcjA80bMeSWBf4on8Mt5Fg/
 jpVuNBhii0Zyq4Lip1I2ve+WQjfL3ixYQqvNRLgfw/FL0gNHSOe9dVFo0ol0lT+vu3AXOVmh
 AM4IrsOp2Tmt+w89Oyvu+xwHW54CJX3kXp4c7COz79A6OhbMEPQUreerTavSvYpH5pLY55WX
 qOSdjmlXD45yobQbMg9rFBy1BECrj4DJSpym/zJMFVnyC5yAq2RdPFRyvYfS0c491adD/iw9
 eFZY1XWj+WqLSW8zEejdl78npWOucfin7eAKvov5Bqa1MLGS/2ojVMHXJN0qpStpKcueV5Px
 igX8i4O4pPT10xCXZ7R6KIGUe1FE0N7MLErLvBF6AjMyiFHix9rBG0pWADgCQUUFjc8YBKng
 nwIKl39uSpk5W5rXbZ9nF3Gp/uigTBNVvaLO4PIDw9J3svHQwCB31COsUWS1QhoLMIQPdUkk
 GarScanm8i37Ut9G+nB4nLeDRYpPIVBFXFD/DROIEfLqOXNbGwOjDd5RWuzA0TNzJSeOkH/0
 qYr3gywjiE81zALO3UeDj8TaPAv3Dmu7SoI86Bl7qm6UOnSL7KQxZWuMTlU3BF3d+0Ly0qxv
 k1XRPrL58IyoHIgAVom0uUnLkRKHczdhGDpNzsQDJaO71EPp8QARAQABtCRCcmljZSBHb2ds
 aW4gPEJyaWNlLkdvZ2xpbkBpbnJpYS5mcj6JAjgEEwECACIFAlNg+aMCGwMGCwkIBwMCBhUI
 AgkKCwQWAgMBAh4BAheAAAoJEESRkPMjWr076RoQAJhJ1q5+wlHIf+YvM0N1V1hQyf+aL35+
 BPqxlyw4H65eMWIN/63yWhcxrLwNCdgY1WDWGoiW8KVCCHwJAmrXukFvXjsvShLQJavWRgKH
 eea12T9XtLc6qY/DEi2/rZvjOCKsMjnc1CYW71jbofaQP6lJsmC+RPWrnL/kjZyVrVrg7/Jo
 GemLmi/Ny7nLAOt6uL0MC/Mwld14Yud57Qz6VTDGSOvpNacbkJtcCwL3KZDBfSDnZtSbeclY
 srXoMnFXEJJjKJ6kcJrZDYPrNPkgFpSId/WKJ5pZBoRsKH/w2OdxwtXKCYHksMCiI4+4fVFD
 WlmVNYzW8ZKXjAstLh+xGABkLVXs+0WjvC67iTZBXTmbYJ5eodv8U0dCIR/dxjK9wxVKbIr2
 D+UVbGlfqUuh1zzL68YsOg3L0Xc6TQglKVl6RxX87fCU8ycIs9pMbXeRDoJohflo8NUDpljm
 zqGlZxBjvb40p37ReJ+VfjWqAvVh+6JLaMpeva/2K1Nvr9O/DOkSRNetrd86PslrIwz8yP4l
 FaeG0dUwdRdnToNz6E8lbTVOwximW+nwEqOZUs1pQNKDejruN7Xnorr7wVBfp6zZmFCcmlw9
 8pSMV3p85wg6nqJnBkQNTzlljycBvZLVvqc6hPOSXpXf5tjkuUVWgtbCc8TDEQFx8Phkgda6
 K1LNuQINBFNg91oBEADp3vwjw8tQBnNfYJNJMs6AXC8PXB5uApT1pJ0fioaXvifPNL6gzsGt
 AF53aLeqB7UXuByHr8Bmsz7BvwA06XfXXdyLQP+8Oz3ZnUpw5inDIzLpRbUuAjI+IjUtguIK
 AkU1rZNdCXMOqEwCaomRitwaiX9H7yiDTKCUaqx8yAuAQWactWDdyFii2FA7IwVlD/GBqMWV
 weZsMfeWgPumKB3jyElm1RpkzULrtKbu7MToMH2fmWqBtTkRptABkY7VEd8qENKJBZKJGisk
 Fk6ylp8VzZdwbAtEDDTGK00Vg4PZGiIGbQo8mBqbc63DY+MdyUEksTTu2gTcqZMm/unQUJA8
 xB4JrTAyljo/peIt6lsQa4+/eVolfKL1t1C3DY8f4wMoqnZORagnWA2oHsLsYKvcnqzA0QtY
 IIb1S1YatV+MNMFf3HuN7xr/jWlfdt59quXiOHU3qxIzXJo/OfC3mwNW4zQWJkG233UOf6YE
 rmrSaTIBTIWF8CxGY9iXPaJGNYSUa6R/VJS09EWeZgRz9Gk3h5AyDrdo5RFN9HNwOj41o0cj
 eLDF69092Lg5p5isuOqsrlPi5imHKcDtrXS7LacUI6H0c8onWoH9LuW99WznEtFgPJg++TAv
 f9M2x57Gzl+/nYTB5/Kpl1qdPPC91zUipiKbnF5f8bQpol0WC+ovmQARAQABiQIfBBgBAgAJ
 BQJTYPdaAhsMAAoJEESRkPMjWr074+0P/iEcN27dx3oBTzoeGEBhZUVQRZ7w4A61H/vW8oO8
 IPkZv9kFr5pCfIonmHEbBlg6yfjeHXwF5SF2ywWRKkRsFHpaFWywxqk9HWXu8cGR1pFsrwC3
 EdossuVbEFNmhjHvcAo11nJ7JFzPTEnlPjE6OY9tEDwl+kp1WvyXqNk9bosaX8ivikhmhB47
 7BA3Kv8uUE7UL6p7CBdqumaOFISi1we5PYE4P/6YcyhQ9Z2wH6ad2PpwAFNBwxSu+xCrVmaD
 skAwknf6UVPN3bt67sFAaVgotepx6SPhBuH4OSOxVHMDDLMu7W7pJjnSKzMcAyXmdjON05Sz
 SaILwfceByvHAnvcFh2pXK9U4E/SyWZDJEcGRRt79akzZxls52stJK/2Tsr0vKtZVAwogiaK
 uSp+m6BRQcVVhTo/Kq3E0tSnsTHFeIO6QFHKJCJv4FRE3Dmtz15lueihUBowsq9Hk+u3UiLo
 SmrMAZ6KgA4SQxB2p8/M53kNJl92HHc9nc//aCQDi1R71NyhtSx+6PyivoBkuaKYs+S4pHmt
 sFE+5+pkUNROtm4ExLen4N4OL6Kq85mWGf2f6hd+OWtn8we1mADjDtdnDHuv+3E3cacFJPP/
 wFV94ZhqvW4QcyBWcRNFA5roa7vcnu/MsCcBoheR0UdYsOnJoEpSZswvC/BGqJTkA2sf
Message-ID: <1220029b-98eb-270e-2d11-30223ac25984@inria.fr>
Date: Tue, 12 Mar 2019 00:06:54 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190311205606.11228-1-keith.busch@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 11/03/2019 à 21:55, Keith Busch a écrit :
> == Changes since v7 ==
>
>   Fixed an early return that prevented reporting HMAT when there are no
>   direct attached initiators.
>
>   Fixed introducing a variable that was unused until several patches
>   later.
>
>   Miscellaneous typos, editorial clarifications, and whitespace fixups.
>
>   Merged to most current linux-next.
>
>   Added received review, test, and ack by's.


Tested-by: Brice Goglin <Brice.Goglin@inria.fr>

I tested this series with several manually-created HMATs.

I already have user-space support in hwloc for reading initiator
symlinks and memory-side cache information.

Looks good.


Given the feedback I sent, patches 06 and 07 even deserve

Reviewed-by: Brice Goglin <Brice.Goglin@inria.fr>

Brice


