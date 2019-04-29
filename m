Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A958C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 10:47:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 551E720675
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 10:47:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="d4vzn3xs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 551E720675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 098DC6B0003; Mon, 29 Apr 2019 06:47:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 048386B0006; Mon, 29 Apr 2019 06:46:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2A436B0007; Mon, 29 Apr 2019 06:46:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A69266B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 06:46:59 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id l74so6987025pfb.23
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 03:46:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:subject:from:organization
         :references:date:in-reply-to:message-id:user-agent:mime-version;
        bh=W1oy+Qiknzzs4w6utFbw9cgJsjZug4WD/Z2or50vcRs=;
        b=KGDUEyHSPiB7Ab0ovhYt+m/IvOblqlOD1jy/VD5C9GyU/8jy+j83fJ9ZmU+HKBRXEe
         sj2kcomwHrnV228LAKd8YFfF7hWQ3weED3tj7k1bov0hAhh5Zzq2uDp12qj3n9Sjymy8
         HNdDfFE1Y5MkDC852/BLRdLKIl1p3qXsvnblWw+MsMeb+0tNjSlj0mZDbgoRXyZQM2u0
         bCLd+M5Uoq4tNXZZhRw7i5wRubJYzdlEPljwSlETJz/ho57gyfWRZmkogDDjNjoue88k
         AqUSvmgpn6NZmqtk+gCbqWllY+w2VdkzsOh3V+ouxIkgbIxkP0J7Tyy0ozPefMRC6OoZ
         RfHg==
X-Gm-Message-State: APjAAAULh4CL1i8AKKBNqEVwkF1DcA6Fy4XJxjMr6KJ4iQ52D5E799M5
	+WHZgXjtmY7xk0k0nU7uWV1ihJlm6bqM9ELoMa40jsXTTXr+sA7pryvf8FmjJkOVqGqocQqEMW/
	ZAGj30Mst1OZLqEm+BRl3/DF2kUarcHp8A+c4OViQeEg+dDpx7CF9QfTwvUPuKWHMCQ==
X-Received: by 2002:a17:902:e305:: with SMTP id cg5mr14526244plb.112.1556534818899;
        Mon, 29 Apr 2019 03:46:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRj3s9mRhl7EDIluaIgP1YFlPvX3Q3CaciQB+9OF3OtvzUz0dqDDAaaWlDPqzTNo9oeZKh
X-Received: by 2002:a17:902:e305:: with SMTP id cg5mr14526200plb.112.1556534818228;
        Mon, 29 Apr 2019 03:46:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556534818; cv=none;
        d=google.com; s=arc-20160816;
        b=aafx7R72Vr1rjgCfRkITQC0m2tYc9yUlqrmO3sunccBDXJ8+1YFDM4tg7KruQUWTGm
         ELe6ttejxf9fW9O/FYxJli5QIu+LzOgSy78J3XA7uQVoXUckQOtDb4r7+SyDJ4c++wtv
         +eeRubQBPdPW6Q0EW6sZ3TlWZ3J23qbqSsfzgu6MwjlzefwI9ZvneAjU3xqPiCXKs8b3
         yAGHVgTjbi0ySMUyY6KR98QTxP508DbgnLJou3BDW9HmKRq436jbutOXnB0bl2GNDXzw
         78L/davqccr2QGcRGEFaFDiZadtXChOdQDABnBvAj8KRPefkdJB3LMdFkZsf5YrUY9YM
         ZsNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :organization:from:subject:cc:to:dkim-signature;
        bh=W1oy+Qiknzzs4w6utFbw9cgJsjZug4WD/Z2or50vcRs=;
        b=us+JpZMAqWcLZyzSEYrw/KN8g1Vb3eUTLVfzlZwLahryf8KaiQ4/RtK5et2tqjxQx0
         Ixk5QhDbJsTxCj7OGpvoiVxo4AgiVTFxlqP4Zx0V8P7KNN9HGVO3KfCA9Rhn1vosK4y+
         2Bo5kB0C8gcup/Kk/mvj9yqaFISFFQQ86lU5NxoNHsoObxpu71SfgqTf6GoGs60GAove
         jrA2LX15cFrftE6qNMZKO8UxLRDGWj1RZcV0+BtWwYlNxzl8N+g43wMLojz86aOImjIE
         1PUikXBN+/GtqFefXKpag4rgpn0S+/76qhZ4RFTHM0aNwv4Jmf3+AwxDNqOuLda3+GsQ
         ef3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=d4vzn3xs;
       spf=pass (google.com: domain of martin.petersen@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=martin.petersen@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 143si30089816pga.118.2019.04.29.03.46.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 03:46:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of martin.petersen@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=d4vzn3xs;
       spf=pass (google.com: domain of martin.petersen@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=martin.petersen@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3TAdHHc136722;
	Mon, 29 Apr 2019 10:46:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=to : cc : subject :
 from : references : date : in-reply-to : message-id : mime-version :
 content-type; s=corp-2018-07-02;
 bh=W1oy+Qiknzzs4w6utFbw9cgJsjZug4WD/Z2or50vcRs=;
 b=d4vzn3xsa1Y3tfRyDs0fEWmHZf2cRfM7hoxv6zgUe5YTwkI5qHBk9/nufJvLCekPG0Ak
 DxelAGEh+0bgJ3a6je2+Xd4ITkwpEGMVfkKoejCmOrjiioPQxqUI8zBN9ooufsLUIvzo
 GjcnK/nPTGyz8sshQQ4+QjwefSw5LKOqhnlPvROXMHdQBV5BbgXoXLcsDL6b+a9vs1Ko
 6iBkVoBmbUg5rPN3nhHppNrkOkSKZSgsMuFIhR+DOzUn3IdV23dV+bPQ/xsqOUt25qK0
 tZXqw2FSfk3ANkjL6m/L+hH8MCmE6WMoZJCxaM7M3JGFwte5gGBw3TO+Q/g2/G8g91az HQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2s4fqpwgy9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 29 Apr 2019 10:46:57 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3TAkqng024841;
	Mon, 29 Apr 2019 10:46:56 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2s4ew0ksbb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 29 Apr 2019 10:46:56 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3TAkpPm018609;
	Mon, 29 Apr 2019 10:46:54 GMT
Received: from ca-mkp.ca.oracle.com (/10.159.214.123)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 29 Apr 2019 03:46:50 -0700
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Jens Axboe <axboe@kernel.dk>, Jerome Glisse <jglisse@redhat.com>,
        lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
        linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org
Subject: Re: [LSF/MM] Preliminary agenda ? Anyone ... anyone ? Bueller ?
From: "Martin K. Petersen" <martin.petersen@oracle.com>
Organization: Oracle Corporation
References: <20190425200012.GA6391@redhat.com>
	<83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
	<503ba1f9-ad78-561a-9614-1dcb139439a6@suse.cz>
Date: Mon, 29 Apr 2019 06:46:47 -0400
In-Reply-To: <503ba1f9-ad78-561a-9614-1dcb139439a6@suse.cz> (Vlastimil Babka's
	message of "Sat, 27 Apr 2019 17:55:20 +0200")
Message-ID: <yq1v9yx2inc.fsf@oracle.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1.92 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9241 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=675
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904290078
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9241 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=717 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904290078
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Vlastimil,

> In previous years years there also used to be an attendee list, which
> is now an empty tab. Is that intentional due to GDPR?

Yes.

-- 
Martin K. Petersen	Oracle Linux Engineering

