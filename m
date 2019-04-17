Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFCBDC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:34:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34C8220835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:34:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34C8220835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4C066B0005; Wed, 17 Apr 2019 08:34:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFC936B0006; Wed, 17 Apr 2019 08:34:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC4DD6B0007; Wed, 17 Apr 2019 08:34:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC836B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:34:39 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z7so14613834pgc.1
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:34:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=MZ6fWnul1xMWnxAp/wBStznNFv+FiTP5DnKRiUb/o64=;
        b=tETGXG4Fur3eg97np56IJRC3eeGNQQh4nJ9vLKX+R89U5WfyNDYdl1/WmhnWLeQNJw
         rN4Z3Ob19nKnpt6DKeeMEWBOeeJXxYYnaul2Qg6HPexRdLe1P435j4Xiu2sCQFZzOj+g
         yLqkP2L11ne4g5RZ7inrYyDICZvExnsVsMSe8SCdZbqlAkGM4F6L29UJBbode1oOkI2S
         ujT+Dhvxr3GUgYigbtcCJO/xnLin2BFNGmouUsOLDMSTGaVsK2WDduE7vkFz+ujbVOTL
         gKXb6oZZhQYvA/2fDxb88kxkdl78brdMA6vojR3W5Lnizew45RclSLGPEZiG+k1C8ube
         3YUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVACLkQkhxAwwowjgIkrOdQRscGUW/IeAatVj1PYDw+hKTNhJ1G
	rNm+SPm4857qyzEsGR9H73tmsMjvI81V49vtzSP70XWoF7TQW7yss4EmZwhHRxjwWhAcwkFbDa3
	Bz/7l4xsPML3IjRS4IucZCP0V424ldZHX2+v46J6p54iIgMPea30Wn/N4xEt0jeXTaQ==
X-Received: by 2002:a63:79c3:: with SMTP id u186mr79721552pgc.20.1555504478537;
        Wed, 17 Apr 2019 05:34:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyy1tptR/yVJdEfn1uE25dySFMs4KRZFvpSKB3LrWBdNZs8/fkG0xg1BgS5bNV5E+f8Rnm1
X-Received: by 2002:a63:79c3:: with SMTP id u186mr79721425pgc.20.1555504476814;
        Wed, 17 Apr 2019 05:34:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555504476; cv=none;
        d=google.com; s=arc-20160816;
        b=TjnFDqiORnJ9fJxtzcUwgspXxJW5j6HnXmBIq+Hd9xvzlY2wjgw3898TZFwXC2iJ7S
         6az+PoJYUkNA2hMUrV1sj0XR6co4NJjgyNIXt+F4CFsXEpozRAd7jVNsP5J0hx0OiJa6
         ZfD/54D/gkrH10FY6goCTsNr60sQe9qGccAoyVCWfRSfiekAp3zusCdT36gylF+YfrYS
         bWfL2PXZmKJC5PBYKCdfh9RznfYplk6s73yMp9YFFLR1B3l5PSipnGUBdJIFzv6hk6x+
         OXtQRJcP6g6t6GM8C/MOcKGB3jDFUqOYY0gmKK/PUC4v0hmFnOi9Ht0Vgrvq5hZWAldo
         vQLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=MZ6fWnul1xMWnxAp/wBStznNFv+FiTP5DnKRiUb/o64=;
        b=dHwQrFbYQr0zm+NWqoV1kSB57CqgShedaAajtm5kHHuYYRl3B6U3+Q+ivjs2wm3DXi
         ohIH9H77ywS3ZSf+K0X0WVzxsQ1xav8rWq1fKfE1cfzt5POZo43CpYsNKYhFJEKhyOgl
         NZwgLoiAf3k3Qpc3uRR2uTyo1JGTHnfvypjMGfwse3iWC53qO9jWtzGwhJIcUbeNf0fs
         W7AsaZi8kA5ZuUeUd7OTzF/88hemDQvLlG4rHJOUBVJcnR4BXwRBqV0Q9u1I2UWnXusP
         Vo3tru2GQekPXBJjr0Bt9HtL182SNfXsLlABPyiSdoTr2XEazw6eOgG09KxRSq6rzzly
         mjgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 143si41489125pga.118.2019.04.17.05.34.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 05:34:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 05:34:36 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,361,1549958400"; 
   d="gz'50?scan'50,208,50";a="165514695"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga001.fm.intel.com with ESMTP; 17 Apr 2019 05:34:34 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hGjlq-0002RA-9C; Wed, 17 Apr 2019 20:34:34 +0800
Date: Wed, 17 Apr 2019 20:34:12 +0800
From: kbuild test robot <lkp@intel.com>
To: Kees Cook <keescook@chromium.org>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [mmotm:master 253/317]
 arch/mips/kernel/../../../fs/binfmt_elf.c:1140:7: error: 'elf_interpreter'
 undeclared; did you mean 'interpreter'?
Message-ID: <201904172010.sZvN8dI5%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   def6be39d5629b938faba788330db817d19a04da
commit: 8e5e08d49bf73afad16199d68c5e61a64f5df69d [253/317] fs/binfmt_elf.c: move brk out of mmap when doing direct loader exec
config: mips-fuloong2e_defconfig (attached as .config)
compiler: mips64el-linux-gnuabi64-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 8e5e08d49bf73afad16199d68c5e61a64f5df69d
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=mips 

All errors (new ones prefixed by >>):

   In file included from arch/mips/kernel/binfmt_elfn32.c:106:0:
   arch/mips/kernel/../../../fs/binfmt_elf.c: In function 'load_elf_binary':
>> arch/mips/kernel/../../../fs/binfmt_elf.c:1140:7: error: 'elf_interpreter' undeclared (first use in this function); did you mean 'interpreter'?
     if (!elf_interpreter)
          ^~~~~~~~~~~~~~~
          interpreter
   arch/mips/kernel/../../../fs/binfmt_elf.c:1140:7: note: each undeclared identifier is reported only once for each function it appears in

vim +1140 arch/mips/kernel/../../../fs/binfmt_elf.c

  1122	
  1123		retval = create_elf_tables(bprm, &loc->elf_ex,
  1124				  load_addr, interp_load_addr);
  1125		if (retval < 0)
  1126			goto out;
  1127		/* N.B. passed_fileno might not be initialized? */
  1128		current->mm->end_code = end_code;
  1129		current->mm->start_code = start_code;
  1130		current->mm->start_data = start_data;
  1131		current->mm->end_data = end_data;
  1132		current->mm->start_stack = bprm->p;
  1133	
  1134		/*
  1135		 * When executing a loader directly (ET_DYN without Interp), move
  1136		 * the brk area out of the mmap region (since it grows up, and may
  1137		 * collide early with the stack growing down), and into the unused
  1138		 * ELF_ET_DYN_BASE region.
  1139		 */
> 1140		if (!elf_interpreter)
  1141			current->mm->brk = current->mm->start_brk = ELF_ET_DYN_BASE;
  1142	
  1143		if ((current->flags & PF_RANDOMIZE) && (randomize_va_space > 1)) {
  1144			current->mm->brk = current->mm->start_brk =
  1145				arch_randomize_brk(current->mm);
  1146	#ifdef compat_brk_randomized
  1147			current->brk_randomized = 1;
  1148	#endif
  1149		}
  1150	
  1151		if (current->personality & MMAP_PAGE_ZERO) {
  1152			/* Why this, you ask???  Well SVr4 maps page 0 as read-only,
  1153			   and some applications "depend" upon this behavior.
  1154			   Since we do not have the power to recompile these, we
  1155			   emulate the SVr4 behavior. Sigh. */
  1156			error = vm_mmap(NULL, 0, PAGE_SIZE, PROT_READ | PROT_EXEC,
  1157					MAP_FIXED | MAP_PRIVATE, 0);
  1158		}
  1159	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--oyUTqETQ0mS9luUI
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICKIct1wAAy5jb25maWcAjDzbcuM2su/7FarJy6Y2k9iyx5nsKT+AJCghIgkOAMqyX1ga
m5moYssu2U52/v50A6QIUE3ZVamMiW40bn1vQD/864cJe315fFi/bG7X9/ffJ9+abbNbvzR3
kz82983/TRI5KaSZ8ESYnwE522xf//fLw+bpefLp59OfTz7ubj99fHg4nSya3ba5n8SP2z82
316BwuZx+68f/gX//QCND09AbPffCXa8OG/uP94jnY/ftq/rr5uL84/fbm8n/06ar5v1dvLr
z1Oge3r6o/sLKMSySMWsjuNa6HoWx5ffuyb4qJdcaSGLy19Ppicne9yMFbM96MQjMWe6Zjqv
Z9LInlALuGKqqHN2HfG6KkQhjGCZuOFJjyjUl/pKqkXfElUiS4zIec1XhkUZr7VUBuB27TO7
n/eT5+bl9alfS6Tkghe1LGqdlx51GLLmxbJmalZnIhfm8myKO9jOUualgAEM12ayeZ5sH1+Q
cNc7kzHLujV/+PjH6/3j4/bbtPnQU/BRalYZSZCxC6o1y8zlhw9d45wteb3gquBZPbsR3px9
SASQKQ3KbnJGQ1Y3Yz3kGOC8B4Rz2i/Un5C/xiECTusYfHVzvLc8Dj4n9jfhKasyU8+lNgXL
+eWHf28ft82P+73WV8zbX32tl6KMDxrw39hkfXsptVjV+ZeKV5xuPegSK6l1nfNcquuaGcPi
ub+JleaZiMgVsgo0gg+x3A7SMXl+/fr8/fmleei5fcYLrkRshadUMvKm54P0XF7REJ6mPDYC
WIClKQioXtB48dznTGxJZM5E4fNRkYAEuWbECNFTqWKe1GauOEtEMfN3wx8o4VE1SzVxukzF
c1A/Ml5oWQGxOmGGHc7WKowlngfLskOwJcCXvDCaAOZS11UJhHmnZszmodk9U3tvRLwAPcNh
c01PqpD1/Ab1SS4Lf43QWMIYMhExsTbXS8AGDih5+ytm81pxbReotE+7VJznpYEeBSeId+Cl
zKrCMHVN9D1guLisfjHr578mL7ABk/X2bvL8sn55nqxvbx9fty+b7bfBTkCHmsWxhCEGx7sU
ygzAuOMk9yML2BPscSlFqhNk95iDjAGi8UcbwurlGTmSAV7XhhlNQkstDrZExdVEU3xQXNcA
8ycBn2C04MApa6Idst89bHJ2IhLF1FNOYuH+OGyxy+2bM4kUUhB6kZrL0/OeDURhFmB+Uj7E
ORsKgo7nIKxWVvxlxTMlq5ISTlS3umSw6/1EKqPrwvtG1ep/gxJUQUMpkuC74MZ99xOY83hR
SlgIioKRipOn56aPVthOmMa51qkGdQMCEIO8JySS4hm7JiFRtoDOS+tYqITYEXB8ZAmsDF4O
Kj+UfvgnZ0XMgxUN0DT8QVCzVhqYIgHtCdolcdqv5ujKFMyIUNkcRaQ4cmC9GGgSWBn09k7D
IQFbx7xEOrVRLPb0VVSm/Ydj/v47B7ss8MA9ejNu0ODUB7raHU3f7J8ZTqGFEAtJnRUaGum9
ygxEYfhdF7nwhdATNZ6lsJnKXy3TcGCVP+20Mnw1+ASe9qiUMlimmBUsSxNfF8A8/QZrqPwG
PQefwjso4XlyQtaVcrq3AydLoXm3X94GAJGIKSX881ggynUeyFvXVtPbvQfb3UBhQVci0MZl
Sh2X7wgp67SllAwpzb/41KxzYFtJYrAoniScomTlB0WwHtp+2wjTqJc5TNIq0t4KxKcn5wd2
oI3Iymb3x+PuYb29bSb872YLxpGBmYzRPILL0BuIcNjBYobDE3Nf5q53bS3iwPZj5MIMhD0L
Sq4zFgXyk1W006kzGY30B15RM9751iE1gKbgP2RCgz4GyZM5TX1epSn4hiUDQnaVDFQ36anI
VGQBC1slYzW+z76i1J2Dlq9v/9xsGyBz39y2wfF+ZETsjBo5NYvAMrAXOa3nmfqVbjfz6acx
yK+/0TbjzelEcX7+62o1Brs4G4FZwrGMILSk4RB/wBHG6PAMTECI8zu7oeMyC4WT4cXI1DMG
3hotlxnT7Mi8MimLmZbF2ZRgiQDj4tznPwsqgffgX0GHi3ZfQLAMHYq2FOIzOpIteAwoasFF
QXuJtv9SnZ+OHEuxKmttoun05DiYZqQyh+E17b0oBmKyoKVtJsDVmtJLaoE0T7fAz0eAIzul
RXRtOES9c1GMuGQtBlM5p01BT0Mep/EmAoT5akQTOYRMGJNxXamjVEDlSk0zTosSidkokULU
I5OwXGNWZ7+NCbODn4/CxUJJIxa1ij6NnEfMlqLKaxkbjpkwSYtskeX1KlN1JJmi/V+HUR7B
sBJWMsUwyqNSZzyXxnpKKMPTwDloYbjeaUprjlbwLc7ZiqLfYVQMokz0Q/xIqOsdn55ffD79
3IPUleZ5H+6UomhjnUEgNL/iEHebQwB4NCJSEDiAWoUYwfPQbOwhc2HANkJUVFvj5TtaMV+C
uTz3Rosh/gtbnELHORG5DJsJ0VVZSmUwX4GJH886JjnDVEAs51wBDwd+tU3Gcqay6wMneJ+F
0QxJjAK6kdtUq+d/tnDm+7wY9ztxq3mRCFaE09mv4j048wpChixKvbVGUhr0zs+mg73LTuGI
4CjaEPfTPqsROAr+JFtmmfKR0W9wrMHCuj6HezxG0jDwpozdK8WXfQI9GOriPAL2cbnOcMQ9
ytn0TZR3UMEdRa9s7021vu3L96em3x5LKAgLwCWdVYNceagSlgy0I4xw/pkQWusIYqRbn14s
Ag+1h1ycLyiX1OYRQR2s6huwAlIlIFmnpz07gJ4CEcSTD5fcMXFS5WUNTDRgl7TsNiXsBkIJ
sOqw0TFXQAhBBeeJxtSdBsfBWNIQ1OciVrJ1Wj1kWxiJDtsyCbG7zW7UmToE6+siHkyfaZG0
nH5yCMCDuPxMMwBotyCiDAVuCHWaB9Q9aE/Qn7zAsswgzTk9J7kCIOe0ZwGQ0xPaQ0LQlOIg
HOfTyXDkTxdHBhgf4WRKVROCnWAKZSnIx95cwgxCrT9XmAoNqyUrThvfWDE9t+xIjc1jDOwC
b9fy0tkU2PHivJsY5TBby5En4B+C2QW2szoSWcq3QWhZEk4wPXrTCxt0HcJcEgpsXhFfG0l0
LmeuTpdBvJrpyzOnU6LX58njE2rc58m/y1j8NCnjPBbspwkHNfjTxP7PxD96EXMs6kQJLKcB
rRmLPfsK2B7z59WAOfOclbUqHNPDZhSXp9NjCGx1efqZRuhC647Qe9CQ3Cf/KODAHIInx4Pv
ruw0bG+7y6Ftg7bCb4tEkea9FbR7Xj7+0+wmD+vt+lvz0GxfugPo99guYi4iMA82JsRUGbi1
fvKs9TN0CVbZB/dOroNR8tkSRo8/yyLgKU/3eaN6vJMD7yXoShphIR9+uWv+/uX5bn32wcfJ
OA/kAtow0WvbR8Ko+ootuC0cUbYoH1CzeRmS0tUX2IUrrrBqJmKBKZk2LUKVT9ozyPdnsK/a
A0zc3Td+ogKVMpZ/Dgilm93DP+tdM0l2m79dWmnfKRUqh1CHYzoPuJGc80zKGUhkh0psAE+F
8whjexyu6tV8260nf3Rj39mx/aHR26+whH+QTwiK8+vd7Z+bF3C3XnfNx7vmqdnekczolGGY
YZUuG8QvHwL9s2/2taxzgckN+B0NfsYiTiUwD3xnO4RznGB1swLLCDHWkgZSgRk7LNMYUdRR
WFa2JAQsBRUE0B8q0AU55kJxQwKCpLRtsROwKnou5WIARAccvo2YVbIiSpwadgMZra3EDnor
PgNbVyTODLRLDx16h+cSswez6jd7sF9XDIQFlZz1Hfb3RwikVp2+C1dmiYdPTag1pMD/WRCD
jbXbnnbxeHI8BifMU9zuLksItlXXgf0k+g46aaOkn+a04+K58ZWxZ7sQB+CROuqQ8w4rqCP8
U6Ajh0qsiwIGeLlMOoePxwI0nmeGZFJlXFsxwNoIpv6PQolJ8hUImSzcBQXcncEJ20gVe9vE
MoQE1DICaz5AsAMM2Zzo1TsIBF3Puo8R8VE+Dw60vG5nAKGCXwqF8C+qBpIF4T64bGgrQVMn
fqzgBnAhH57tIOaQnkFK0+E8cR/LOTizRrZxvVfeTC2P2ELWWNXE3btwF6RUPScUIZifQNs5
ExDL5cev6+fmbvKXCyqfdo9/bO7dzYHePgFaG6NSxjmrZqBh8UJPHF9++Paf/+x9AZCFHCts
vsK0ZSiNhRQvDHLMGLjStqkNJdEzptxoh1MVCB+ydtt1D/Qpt+pqJGHsumsV76+KjRTGOkxB
uyItGI9FgYqmbzgokcMc4YSSeoFlutFlAm8ojlshF5VnyaIwJ4Ylbx1rAWzzBYP/EILF8EgH
Fz+85rHbTn0Z3fCZEuZ4sR1DfjoNiRhd0GPNBp2VRbSriAqb3BBYkUv1cA24gbJk2YGbU653
Lxt0ZSbm+1Pjl/w6LxZLsFjyD7iEgaNT9Dh0FUms3sCQOn2LRi5m7C0cw5R4AydnMY3RwXUi
tee5D27jJEIvDhwwL64tYKm6io7PQcsMJqrr1eeLN2ZbAT3rFR8fN0vyNwhhxeONoTKQsbfO
SVdvnfWCqXzknDwfndxfjB0vPr9B3xOM0RGsrB+EoMj9+ReMx8M2GzS5i4lyom//bO5e74Oa
N3QS0iVF8CYKDu8p0R64uI6s+7WfaweI0i/ELEVhF4L5eqt9YcrhTUMHtwa3GqT0D2Fk3yvQ
Qnyssw8Me++Nob0PmuxLClTg0KKoqwEC1tJv7HbYreX/a25fX9Zf7xt7ZXxibxu8eJvcB/6D
QXoAelbG23poCqMs/HJJ0e72LPaac0wX+ZbVUdSxEqU5aM6FjkOSSLFbR948PO6+e4HwYfy3
TykOXVB3gRZtXFjJ2KcgbUV76Prj9RZ7RHiFCdRXOdgf0AwxJoo7PJ9wBj5WaZw0lBBBnffL
AtmIw6QFKFg1zGOgq8WSRNVmnzj3gmb0wqIqvGSjc4LVu+OwbiYoSUvz8vzktwvfwh868dTl
PA7cVoLzht7iIsh3xBkH84S5bFJzpBClGAxvR/QKXR29KaWkle5NVNH2+0YfXn/pdULSXR7p
IiNikXtfd54HK4RP2D6lJO0RwLbYhPjoTdBZVdYRL+I53gQgN9e//YulnWKmgoSBXkT4goEX
1i/spKJoXv553P0F7vChOACfLXhQcXEtwLiMWjuavH68yhrUONgF2zbs3fNRRvmGq1QFNPDb
XtgiaVgomPG6lJmIaT/O4jiZofnNEUGR1iDV9IHgHi/4NWkd/LMQpbt1GDMdbCW0d05ZrSSE
ENRNJECyMHzvorVIArJlUQ4IQkudzGMqld9CMQlP9VJMUb0sI5WivHwIFy7KGeprnldUMdxh
1KYqsOT3EAyW2/XQHsp1AdpNLsRICs2RXRoxCk1ldQzWT4oeAA+uZvNxGB+5BiPc1FA1j/BD
vxl+o2NENA5OhQZVjCGGIzAGjngoqRY8LmlxiWme2Z4FiWnvceIq8k1bZxE6+OWH29evm9sP
IfU8+TQWNMIZ0gUymDI+vcKs2FDLHeCAfbM5CJDSvKRVMaAO82r7Jj8gat+w7RpUhuDivDS7
g3duB/0P1GsPgr/wVlR/1j0ohVgouwYjEcjgQVf7YuDYivaI7jEQMVKHkMnZQHgHCBC/0RuN
V42Lwpq6MQS8vw90ICYew7CFOPKm/n4i7lGdhlnag1hZV/N5cvv48HWzbe4mD4/o1T9Th7Ay
9mLcsOvLeveteQlqFEGf9vKDvcWvK8rrIdGtCk6v6e3s8RJNKmAKdZ69RezA3B/FRg/FXt5+
dw84wXfOtd3oo9SK9P30inSUd3sktNCY4nljXEB694qxvLGizDaJbN8WvDV6XOb6LR73kGVp
NATs5ZBtIaqCEHacbXNmwLdE/9tcl+9YsMOPyvStqTlEfCyG0c3YalussnofuSSOh27DAQpf
jj+MofDfIVkOk8fFCGO1cP3W3MCFn9sHuu8b8IgkO4RR74DEBW9gNs53DiubmnfSy3gxM/Oj
G+LeIh/DyFn8BlyRJq9HQC/YujjH11WkQ+t3DHtgvo4gXhXgCRwf+jBmOIK7MCiGR5f8pZKG
HcXoFdwRHM6y/A2M2EnuOIqOzVssr/FJ6jv5fR8cHR/U2IdAx1Cc8jyOgqWmYwjV2XQQZWhO
MxCAloGmdsnD8r9HXD/fnXFbhB4sfbsMPR5rX46iJBDLH4OjWzWIx4bgYfceqvjvPHZT9KKN
EkGi3LtaQXtrWOZ0u9Ol/hbuQap0R0HHm3s0Y7Ih6dYxH7R2Vt8u4XA2xcy/hhF0CRR+ACEG
V+xq2ATbTe8N69ZIAPop9YUGYkf8rUOrOAZDESVhKhmprIFRGamm0Ff+hyajn7YSCZmzc3c/
rFfLBiELNpHElhkr6s8n01P6GU4CZzUinlkW0w8JmGEZ7QavRl6tZKyk7u2W+GgjsECCc46T
/TQijty4W5X0WmJqkKTQ+C5Y4g9xBMwB58JsLY6upJW8WOorASJD76vTPqPJERvOjYb8eTmS
9XDPm+kh53o0lKjdTEdjPwwuzvCnHFBVH8Mq4vCRuwdSK0xSX9fhg9XoS/AaF992/k78VkWb
2Zy8NM8vg2o/0gb7Pfb63zK3kiDfshBmJGM7Z7liyciDr5jRlCOa7xnopJUaE+a0XsRUkHol
FM9cDqIfOJ0hM58e7MYesG2aOwiRHydfm0mzxcjjDks6E/DvLIJXPGtb0Nhbf9jed8db8Zcn
/YhXAlpptZUuBHmfA/f3t4Oc4m/lkTuPMRN0miLmJXqvdFm/SOktLTUDcRgNoWqR0rDsymXh
KJnXph7c94fYBqbnHjyHvMWXo8/mUiYyuSRNqrtN1LJ7l7dKmr83t/61TB85KJgOP9rfSAl/
wiMWHF10kDp646BbToorQr5UQi2G9I4cKkK1GXkLjEAhabWBsFLReWALw/cGtNRKg5d5EOtA
RLDt9nH7snu8vwc/8G6/pU6A1ncNvrEGrMZDw99keXp63O2v1SbN8+bb9grvqyJBm1fUIQq2
8+3d0+PG3sYNps6LxL7UImf3/M/m5fZPepLhrl616tmMXPsv43jsKZ1ipRjotf4y7ea2ZbWJ
3FeL+uqOex8+51k54gEB55u8JH9XB5RMkbAsuMVYKkdxf8PY/iRJx/r7O8n3j3A2u57306u6
fWiw99n4yii2p4O/e9VLXIftfgnkcPadHs4yeWXv/3iVZW9leGnHvRYYWbpF4Es1Ut5wCPjT
Xy0Z8CFyUAW064doDJ/gdMj21i4x7f1LQbyxWRnZ/T7T/k3EndUgwUFGKs61ieqZ0BG+OaE1
rwRVGI+Zx1lBpsRyk/h6Hz7tUkauqQHUvzQyjsXUr4cYg7tRT+vd80BUsCscpX29R3evnvHu
vMtA299VMLv19vnexoaTbP09vG0C5KJsAWfshRGuEav7g3W7qwGKdiBSQ1euizGAGIWoNBkl
p3Wa0ApC56OdcPJSluOnMVqpz/2XFTxpvcODTVcs/0XJ/Jf0fv0M2u7PzZOn53zeSEW4z79z
CC4cgwftIAM10Qz90Rm3v3wj/V/86YCFbO/UhywJkAh0UfvGe3ypiJi9F3HGZc6NorJPiILX
LyIGDv6VSMy8Pg0nO4BOj0LPDxcqTom26XDhciR63PcoDDikK/I5WLfdOThK/8/YtTS3jSvr
v6LVraTq5I6oJ7U4CwikJMR8maBe3rA0tnPjGsfOtZ06k39/ukFSAshuahZ5CF8DBAEQaDS6
PwTdboDZX3RTt4WK2p8NDA62EjnD/GGmiCX67nTGWnz6+ROdH+oBZlRhM+JO9zApdmYLNOLC
K2KT4qkjM8UZ7xv092nVvU6u/dvYqpp2LHfo009PrqasSBSttjCV1Y/P376ghnAyp2cgWs/w
lK5gCorldOrxH3PU1+LZpg+FP32wmQFHWMP2SwRP7399SV++SOyJjorrFBKkck1Tq5khm4SJ
SBjOAMDboCk9yoIgH/xP9e8IwwQHPyrnMaYJqwxsC2aqtye3S1qTTSnLduXzj2QAjYqPM2rt
OXBR76okWvVLqGOD2reZ8ptOtlGEP4hcErbJMZUHNxJa4whAsg6OSqYW3sYhtb9t4AgWm66T
N6YahzQTOnCJeGhwmR+zIjV5f3QfGeRL3oPbvPQVXN9cwQ9UvHCDwldxme2sxPplvBmFmZ23
8byzWx8NGTLYWXOqk4z8eiv0ofQtzc0R2Hf87pqhBtt+3IqWoTk86rzitSbMtdvvlVVmF4fW
fqjb7oiTmg8Apbufrybwp/d7SocVwXQ0PZSwm6I/A1Dg4yM6z9IfyUYkBccjhRQ0qaTthYVa
xWaDQGtpUi/GIz0Z0vNtmMgo1dscWV/ynZLMTmGTlSqi9UaRBXrhD0eCc3HS0WgxHNITZgUy
LEGweuo012UBQtNpv8xy483n/SKmooshPTFsYjkbT2lTcKC9mU9DGR7LbRh7wha2MtWeuFxp
sZj4TP24BcvenHcImi+f1qg971Y+1GGGusl7d9xXCHxrDF9BjVfh530SsTjM/DltDK9FFmN5
oD2vagFQD0t/sclCTfdLLRaG3nBIV1cu596wM/7rYN6/T+8D9fL+8fbrh+Gpe/8Ou/eHwQdu
qbBdBs/IoPYAH/TTT/yv3U7NuImUHoNq2p0HBB7enQarbC2siOHX/7ygdaB2Ihp8env8/19P
b7CXgyI+O9MFntoI1EOzboCNevl4fB7ESoJS8Pb4bOjTW2afiwjuqYMmUrlSyaRaEcm7NHNT
z5UBpGyZ4FoP2by+f7SKu4Dy9PZAVYGVf/359oraLui++gPeznaS/yRTHX+2tK9z3bv1hn3W
/pae+UK54bjRtETqO+QmlbQiZERgd374BxLwmTPmetgBiVJQtssqFjRwYrnhZ1e1xpOKWpm+
dH8zQDEkLU6dCKtcqABpt3PS4AUZLO9szO7wHZkU5NStQsEuNagfbdhxBp/gc/nrX4OP08/H
fw1k8AW+T4vB4qyNONWSm7xKZeawGk41yUJ/LjPvKmU6L3cwSTrRys3D1mQV3LMu+9Xh/2gT
dNkqDRKl63XL5dMV0BKP2dA6Rvdh0cw4jsZQZQVlvdNjrshKXpNQ5u8rQhovKrguEqkl/NMj
k2fXionSvaFC4SUCqhccXnNUBkEXXKYYTI1hDNZARSy7BNpIyzj+n6eP71Duyxe9Wg1eTh8w
YwyekJj02+nend+xELFhvu8zara9SGDMi6lESW82olewqiATddP/MK0iko7HYKvV+YOE17pv
v+/9r/eP1x+DAONSqHfNAhhBARO1Yp5+qzm7alW5A1e1ZVzNIVXlIIWuoRFzlj/sQqV6Gi2m
j2IMlvRgqDEozXj81y3dBzLj2oC7PQ9uo57e3amext8pUO90d/rP/nlzZmaYMTWowJjePFVg
XqQMi4yBC+ipXjzzZ3O6L42AjIPZpA/X0+mY1hQr/MiHexuBcCWYOCdEN1kxnvUUj3hf9RE/
jOgT9osAvccxuCr8kXcN76nAV8Ok1lOBWOQw39Lj2ggkYSH7BVTyVTC0mpWA9ucTj6FsNVv3
KGC/6EogKxQ3CxkBmKdGw1FfT+BMBs/hBdBFQh97RkrOnD8YUDOeMBUIW+Qwx2CQnuJhcpkx
O72sb34xYJHqjVr2NFCRq1UUUiFQWT3LuEY5SNurZJkSNsdMpV9eX55/tyeYzqxivt0hqwlX
w6+/46uh09MqODJ6Or1vCTYSt0FP9vyOZcGzW6jcRctOKzVn0N9Oz89/nu7/GvwxeH78v9P9
7+4BERZVn31aB8qYeqZyu2wf6BHcBH5w1pzVVlOsU+hRNvDGi8ng0wr2mnv485na+q9UHqIP
D112DeIZFOORDPqzcm66iJW1oUjqmjvWWWhXTnE29jB663ZrKLbIQ3ETWeeQ1Ztgt1BQBt1Y
SPQNdE5FIKlgTsZUhtIktDtwCHY5c2a+5o6vhNSMmwRO07ANSRlfoWJLVwLSy53pAHP/UkRZ
V3ctq2oSxRw3Rt52mKxGEbpEXWwnLXeV4On94+3pz19oqtCV24iwWNC63wtUB+lvWlHE1W6u
HEvXzB9G9Oo5llNmSdqleRHSc1JxzDYpyQZh1UAEIitCZ6TVSWizyVeKJJWzC1iH7scQFt7Y
48JXm0yRkMi14F6bpSMlUy7i55IVSa9dvhWWtb62PhX62kvE4s6O8ncgl9wlDnzP87BbySdG
GP3IGDqhVI6KXs2mV2oIk0VSKEHXMZd0Oo691NnoiyLiXIEj2niOAP1GiHDtfm0AbGGr66zi
VUqZLH3fXcW6mZd5KoLWl7Oc0IbTpYxx6qItMsvkwBCscwOqUOs0ob9RLIzZ5x11EcbswSFk
ZKJDrBeWwrWjLRPRnwcztC4jggmZcqt2MiGxvJ2n2GwT9OGCBikz2lXUFtldF1mumenKkskZ
mZr4PmNWnEjdbts+dsRLbsJIm5t1LLOZSSoL+hM4w3TPn2HGdn+Gd0xM1blmKs9d8hCp/cXf
Vz4HqbR03qY9HRJZYCyqxPn+gnjBqY9BwoUvNeUFYVdX2UaKoz5ocplwbrsO0Yi59AKGRnti
7ZYXxtvIXNF0+UrC0dW6h3fu7YcWtHF8lDaZd21m2mzFPlRkWcofTQ8HGkK/FKcDOcLskFXx
DcIcjq5p0z2kM5+rOnBZAGAeMmGfTs+kX+MrvVnv9Z0JbBdzkQH6Zs3Ywm6O1MUz9oPgKSJJ
nYETR4dJyYQxADblNy+A6n0vvNpfqY+SuTsebrTvTz3ISxs2bvSd7086pzh0yWk92m2NZT4h
L99o59RhTI/t+Jgrp/XgtzdkOmQViii58rhEFPXDLnNKlUSrT9of+6Mr3yb8F2/odPnVRsxw
2h0YqiW7uDxNUput00bduqsSysOwNtCWMRi8bKsk3RL88cIhwBcH358vOIKPETcvAHTDGjWQ
4I42w+wDf/j3+EoL7GCtddaQ6hbYlmrczZjeOK0D8uTFaFaOmh8pTNYqcck+NwLvjqFf7xii
a/lKXdkC3UbpWjnr120kxgfGueo2YpXD24gZ8vCwQ5iUbD6SJ8au4RYPcl3iq1uJHgPw8mSR
eXx1gOWB8875bDi58gVhwHQROiu2740XJHkAAkWatmUhqcyYb67BYZcflsVetX2YO4K+N6Jv
YkMBwx6dHzBgkNH+c9+bLa69MQw3oclPPMeowZyEtIhBY3EOZjWunO1dI5EztJm3bQAJMlfw
x2XoZwKxIL1c4Zi5MvS1ioQ7IcrFaDj2ruVyz46VXjCzD0De4sqo0rF2BqKO5cJb0Kq0wRgf
mkxJTm3CRyw8JqMBJ9dWD51K9K0/0HYcXZgF0nmNIkZi1es9vnUvkhZZdoxDwZzdwagKaQOx
RBadhFkfFUMucq7EMUkz2KY6yvhelodo3ZphunmLcLMtnAm9SrmSy82hSpmB2oTsU5o5UG9k
BGc0bJkuiWdW5w7Og+V46ntXbC+t8wb4WfI34SG6w+soWmzH3WL36i5xycWqlHI/5QbyWWB8
bSdywIs2HZW2SjFLRqQYqrhVwJwwgM6YUT2K+nhZGcytMANMRBZM2yBt0iQyVitu0apkVLEU
jC3dCMDnKtEkz/i/o0htSiDqCwMsUsuGIQhKGUBKjyO/iE10AW3kqk1yvABeTsyChT8c8zA0
1RxUkD7cn/fhtY2sLdDMFkqKwNTc7qTaLMDkCQR0c1WinSnIUPkesTVBvJC+5/VK+BO/H5/N
WXylDiHfTUpm0VbzsAkKOezFkRWJtEKr9tDzJNM00aGom6UZhtXmtd1WTTJsjtinVdu/Xtjs
4f6BRMG3+XlDx0pUN/iITk0a/bPJbL9frSGyZdb6FI+DTtX7brhY82ARekPGgQPPAWB6VJJ/
eO2fwuL1BLqGWWOU49/U/JJll0EAP5Ah3Vz15SQG4Qrv2XIT25yKmBZnWUvKsD3VdrNLctqS
Mj56bpKJaS0Ka4zqSGX2r410sfP1A6F9QzkC5va7Vpphy8T/zS4A+oZXpA/msi97NUJIioJe
CBC8EXvujAXhLFwLzUTTI54XEazr9Cp6wWnrP+JoFfGZLSDi8Ic7VUBYZRta89u3FO6GbAJ2
3NTBF4pfjuriavdFYYVzkgY/e/gBAJ12jAJkobHNjGpD1hEMgTYWaQJqbJ0MlMOOxFGHU80d
Y2e50vGUctizC71YESkwDJRg27S6hJnBzlthCrQdkG3AvlTDTi8Y+btjYG8+bcjoHmGSnJ0S
Q8M5Mtg/IW3Ipy799GfkJnl/fBx8fG+kCH1nzzkGxAc8veSsGxiazShkxpOBIN+4LMA6YOhi
dt0oTPXy89cH6yuukmzrMP3Cz3K1QiL4NqFLhSEBDsehU0lUVPQ33P1rlVAs8KKIttA50P35
9PJw8Vh12rvOn+ItLr31+Joe+wXC3TW8NR1Y7cmRnVQ5b8KjuXjVsUjXaTApZdOpT9/82RKi
bC0XkeJmST/hFjQvJujJkhl5sysyQc3jlM982pXiLBnd3DAheGeRQorZxKOtsbaQP/GutE0U
++Mx/WGdZeBjnY+ntK3rIsQQql8Estwb0QecZ5kk3BfcNSaNDPJp4fnGlcfpIt0LUKuvSG2T
q419KFoi3Y/HctbCn2WmR0RSKSL7kt5L+vIYUMloGIZ/s4wCQaESGSqUFFh78lKQYX424W7O
kckZDyOc2RkPTevxIa6kjEXZelq6lZsbkm71IrRKJS5nctOurw5zJaJuPUWWRaEpuufxsEWd
Lua0Ia+SkEeR0ecPFY5N0Q5Ka4nAGOD8KioB7MMlYyuoGkB63jATTCy7Edlp2IqLvpqeB8OV
6l7kuICq83SPLKD0aXglYngVGTrOSgD7R8NmkjnHrD8f0NXovVisJnTE4eb09mDCANUf6aAJ
92n2AnjGZoW3dMPqWxLmZ6n84WTUToS/2wH4FQCqKwxbYkhXcKSW1fffypYLJq7BoLWvWKvg
9pP1KG5dCNsuJpdXykgjaAWRMXcebI0QCa1FHJJhsPL76e10jySrl4DtZt9bWJcr75xrio3/
ZXVDQiRaTC27ohGg0s7X9DZa+p6UviTjTUKBc1Ul3liy8MusOFpPrTyI2cQ6in80nblNKiK8
pbMiumLIt5L0LuUOj8u1pueH+p7sFqVcU63ABFhukQvBvkIQtLDqoqOL+Src3bSYGGpGkben
03PXY7R+JevSXhfwq6vRu4nwJFh1YFdtLrRrerTdVEZyhZst6rVsoU6f2qBDe2cD4UHkNJLk
5RbZoP49otAcbzONw7MIWW9z0U7AsIY6TcF/6ucHFiPfZ86ELLE4PYhO3yWvL18QhRTTicZV
mPBFrwvCd2ob3V0J99ouK9HqhXapX5lxW8NayoSxhp0lvJnSc8bMUQvBMj4b94vUU+fXQqzx
Tf+B6DUxpBy4WlTOHH5WcJ7xkzDAKx2VUXbtGeZ+S8bMBFMrGiGSglmls1jBopcEEc06ua+v
vnXMHU2iIeeGdSBmTvuCguHtRc0MrfT0ki72fVR6hYQ/GX1b2a69Eh9UFB3JYHpQgLo785Fl
XIQfpdHsVbKyNAFMbt9QaNI2IBruHHJhSKbvSEKkoho0c3NjHcFKndUWJAd4b1NHDnSM6d+R
AKCfCBIfISLlTcf0PvKMzxg6kAZnQukMHgfzKb29rGH0QmdxUKd6QC78C0GMcKJVdkQT4+FD
f1cGNy5B5Tqj74tCEa30dLrgWw7w2ZjeytfwYkZPRgi3AlBdJMvT5uTPDNLf7x+PPwZ/Ildj
zVL26Qd0//PvweOPPx8fHh4fBn/UUl9gvkf6ss/tgRCEWq0TQ6LZG7/VlmU8slAsXI+GjF6P
vRcztz8BlvLbctO38kqQWdXAMUduinB1CNL56MO/Qft8gYUQZP6ovqTTw+nnB/8FBSrF3d2W
2S6Z+lZsW6DPw/6BlcrTZVqstnd3ZaoZMmMUK0Sqy3DHv3ihkmN7V2YqnX58h9e4vJg1YNov
FUbhDRdh3vSAYujdTeNzrL0GjAQTgVUNLqQ55RmSziIiWtPbi4sIt+KpMbPiZkxMeMbo3BvN
BDJm3fUEnf3vn1/v/6L0KwBLb+r7eLu6u1u2jeLVqf8AzbAJd8+ZZR0/PTwYalMYzubB7//r
PFIlsshpH5V1BqOaIc3e0zNylu5xrdox8bIG5X3YKlxvYdWnDW2bPRf+hrFBMeNntMf7JQLy
zimNh2+p1mrZ0kk1FVsCyqMgxZet20Urf4xfzx9P33693Bsa2B56xVVQWZeGjF5qBILFdO7F
e9oojhLikI2GB95is0LLaxAyLrIIB2IxnNHL4RlmSBQrmDuiNHCU8EXH0kMXVbbym0Iaum5J
Px5NEIpRAxDjVAR89FeR3JUyTjlXfJS5CeOMiV9H2Pez2Gd8nC44rSRU3XLwJtP5vE9gPp8t
+LYHAX8x7CmgmI0XPXCYrEbeMuZHzk5lSOvCGSRQJA8LWk9CMJOrKQwe/g3yQI45NgWDF9Nh
T3atJvPZoSdQAWXiKaNHGvTm6EMvMOGEy8N02GUscws4asndSQ9wgbS24/H0UBZaCobPAAWj
bLyY8G8K5UQx3dBFpmfecMoEpAE4HTI0DaZgI+DTanrz5Myfj68UsfBGvZPQPvJG83F/W0bx
eNrT28VtfOip6O7gT/mvTeTqLk1Efx1jf8E47ebhegtaJ6MW5bLnxfB83qxulNVz/Xb6+f3p
/r2729ytketlaRkjqwRz0cYar/32LBNiwGjDkF4GWSlDghQPslxMrVWSzAafxK+Hp9eBfM0a
3rfPnWuvKuE4GERPf76d3n4P3l5/fTy9XApavZ1+PIKS+e0baJ1B2567WjbU7Ze3g7QkLfAK
TSvJictoeP6hPamDNCwU/qxgS5/jDVG/W4BMsyNkFx1AxWIdLiPlWAawJOhR2OogsaMivXJB
ZinkjdHsnVKNG1G1gdetQgsVmWcVLaqFbqt9b3b6hO6ANTdhlmSfA5rF9IyGGY/LMGdDbUAA
FtwIXpjW1Ux76YIF+89VQUB7gcfGpeAgMLtvDs3VjsXUfMK+Ezo3pJSpBcsE9ciNqDontmeL
Dm73P5Gdd1/Cdi6O3og+WK9QtgnpKRIRsRNcxNqS5bPBVg9T+AoUPTUCfnPk7iJYluNgxfbm
Lk2DNKWXX4QLfzZi36bIVRDy45C7/NYMf7ZQCdMe5/aObRRrueXfZxvQew0cfsu4XB+KyZT/
snYqL7bMbgUHaRONxwosobn4T0cr9uIi82ZzjzpuPA/hMpJBs05ZJ1eQaG43vnjIX5RsGZC2
mE7JTgG/u/iFi+eytzqDoEUvJh4oEMyJyUVSBJnvMy40LSnGGcdqjHgMyvM1od10NJxHzL15
Z7FlAAoarYdb1crlQSZdxiBYe99fnw317c/nU0NmRNkRUEGQPYw0cUDijaZgOK9l+7jMSYZ/
o22c6H/7QxrP073+92h6nihzEYcVyTh1BETAMEgKvKIyy2FZzpkpkMiWp4U5/v3HGYIQfuUh
aJXiJmT9+qJ0TREx6HSb2P7EicWwDj+qgw83KZOxm6DD207QCabnYh/DEmh/Z5icao3UAFRl
qtLrh/52s21y/s5vxINjImKFsShJSjPRJudJwUQjikw5L26x0FqJDRsogivdrtQFZQ+eTN3a
q6ddRHU9jPtUaNIt8oXkREvjMO0mY0uX5h4pGnNT42w7GXrmTM8FhFzMYWQhg4STTviMm2SW
TssUhvcSsCisIVgxFo+LTDCMm+a9qqNcb8bStJ/fk68gvm1ttGtZcy0p5V4KajIGnF2xQj1/
QutDBr4rvBljTqnx0ZjxZkRcxsofM/rWGWcObQyuJ6Mx3ygG5p8eIjM9/3CAOUd9021yxins
CK+32qywjP5Wi+A1ZyGjXNQi3G2NCH8Vd3c9zZtm0VgL5rQ6qXw5/svYky03juv6K655Ordq
lmztTt9b80BJlM2OtmjxkheVJ3F3p04Sp5ykzum/vwAo2aIEyF01NWkTEFcQBEEsXy5Wp1a5
RTsx24QmqCSIgo0gr9JsenL7hTcyxsJTS3n+isJXmQxewlYJQb7jrBgtCzfD/XJ+fc3LIJZR
FFdjZDESCvYIpsuqYIKBSNX1tRANsgVLOSEa8MiWUkuZXrzyWtBa0W5TZ+dno3tdepwk6lmt
pfSu7Va+Ht3p05G9SvFxP6lKDPKCOOUqlLsXqDxSI7M6M8kYOFLr0c9t9YJvelu9DLbVy/A4
TYT4ybQvZRhmAbgUArfjeZIERnj0O4JH5twiBF9P1iAvbVuFjKGT4vxSym5ygMu0FcaS0QMJ
c4Fgb9kC5X0MYub555FVI5em65Xc8xZBbuImzWfnF+fylo7SSF79aDW9ml4JeiNLOivRzgnA
SXwh2JpY5rqay0JwbjDascy681gLMQ8bqBDS5gAV3hesRDbl9FJW1FPXcN3v3wSa4hOMm3QN
aSHvh8Xq4kLu1joOuTS48+APUg875oFEfMpSiDAUhGfobxalvs1VNb1yJGuT9W4QVeH1j0P0
SRznq+TUqM5HtpB12TSKz+zUYkz7IUMHGHMTKiFGJp1efiCqWNsqslSwAD3C5+MYZZoMbKkH
SAsFIv+IaMmGLSIR30Y/sOtuguELBRQ6dn8mwCz2cCtb1wWImsmMdR4FNLjiOm60c1ahj/Ud
FUPW2vh1e4+WqvgBoxbHL9SV6HdCYD+v+MkgaCYp0Aha5VJMExq7jm4ML1Ug2J/rXFBoWLCB
XyPwtJoJcfMRDBftwNxoIZo6VUAPUTJ4JGw/wmHRZmmSS9kaEEXHRR3yxksEjrRk00ngO+i+
CJ3p2DPCMzTBQ+EBDIFQseznQwhreVRLFUkJFxC8MHpZpFJULOraOpdVU4iAYSzk9qUwJwj7
qjzBsAOh5dIkc8EX1k5LUhjYpSNdi3y658twnaQLnh8TOJ2Z0e1Ijw7kVTSCEpVSPgULX4dw
+ZXbyLWlXbkGCiORhjwfJYwU3bpHyJMiGozTWCKEzUcYxr/m9WC0t1WCdk5ROkL/mS5VtE5k
1pYBe4n8kQrQYy9HQpZ5ACll5SYKZcaG0QQUk+GZ1uTfKmP0Y8f3oTpCBZeUGdGQpyYGUpFp
RbL1w32MTmiqGOGhFFLia7oebaI0IxsGOE2hhXcOgs/zqiiHqbEdpAoP2DoTngkRY2WSWO7E
nc7T0SGgS7+Y44QmghLy1VK6RTpMI8ZMEi1XXVHjKCSQ0CXJCRmJIk4d3g7Qsv3ufXe/YxyU
KDyH11HiY0Hrhns0t+c7Qwb6bGewlhRzUeEbf6Qb4wG3lcEbGwmlaRynPURyPJyrop77bkdd
NMeLib5LkrRKfI2e0PUxE8QhJer26Wnzst19vNFkNbEV3KkJdKiAp9VowmAK53mbwOKzgYOW
lpz+voHUy7lB799h7Qj0InoZK8o+FXXHWZVpUQHfoMeCSK27Hld2PTm7DYQsac49FXZvVw5g
+PxwJC/0rzhmMhvGHKA6pp9XZ2e0dL0mVkgfc18iH92A3TWl0jxNaT7qsmSgZYkLXoCgyX3b
0y8eysOCF2m7XRm3uKclW1UX52fzrD8uB8kU2fn5dDWKE8LiQ00j85Oy85MeujocZzo2jA5e
1dbcW7Aiwshfco/yazWdfoIbE/MtNosZYem6zlJTE7jCf9q8vfF8Svlxb8fnFGfGLVwGnRdG
uh7Gfnt/S9JS/++ExlKmOdqIPGxfty8Pb5Pdi017+M/H++SYEXLyvPnZ2nJtnt52k3+2k5ft
9mH78H8TtDDv1jTfPr1Ovu32k+fdHhP4fdu5vW/w+ovSFI/YyHSxmlg1J/ECVapQjWT5bfBC
OMyl20gXzxR4kT+JBv9WciClFqsIgvyM1+f30QRLxi7a1yrOirmQwbqLqCJVBZxLURcpTWws
BGmZblQen6qjuUNieiXfkyqCG31dedOLkbhWleJFA/O8+Y7RgJiM3sTtA1+yxyYwivkjNETB
wgS1D31P2zkQHDbpVFwKluoNUI7UhfHiTKClCUbG+Xl65m7vpnDICg+AFNhObm0uDnPYywfk
LhG9DrNT74oNwvc6NoIjQQO94PWkxOOCqmSdIW3HFoWe9VlrblLJ2Iqin+lZWoq3V8IYOYda
WvbXn33B/cGikQuKfOQF8u2WjrsSDRCkhFU0MaiTCmBNIyEMDU2QATnIW8z4uwmNVR4qRk/w
QUr0ctHAmYaSLlUOcy5jiJnPrSxRaJscHWNdlhWbk8mSL9pDhcv+cq/hEzmWnb6j6RRy4dDW
rSji3cWn85V8PswLkGrhH5efzuRFb5GupkKmc5pwjNQEa6bz8Xnx5yoteqqvw7bLfvx8e7zf
PE2izU/eDTFJMytU+trwdh8tS7gU1OIIn6lgJnhnletMcKWkPUiRNJamFDQfxM6jzIjueNWS
X4xYckvRsRxUBu87sFn4lpQP16DCeCYygm2tgf8nxlMJJ+jlpY9BWbrHGhaR4QVbW4B+V3T3
GiwtgLwq7Ny8Dh9RhMvQCFpoVa0YTtDOpEk7B4RJa9+4txsM/RLkC1Sqm5x/AEGcAKb4FI6S
SMJGvPFTQflQ2cA3rV5fxMFkA3IFeSVMOULjcCq8c+KTWGuSxcwfgvF7nVRupGwqluwJ2q9i
91mquWvf73dvu2/vk/nP1+3+j8Xk+8cWro5cjI1S9dOWtwRvsuJwcenc5g+fztIoCI2kAF0W
mUlYv1Kf/FGL3cdecFBUJvJYo3mTxnHVUWM46TcJOMk237fv5LdaMOoT+p4E/3C4OfLt8+59
+7rf3XO9ynUMQhzaFQ4/fH1++85+k8VFu1LsLJE9Zz/dpn1xgnb+VVgn+/Rl4qP7/OQNn6G+
wVgDN6+ien7afYfiYuf3Uy56+93m4X73zMGSVfZXuN9u34DRbye3u7255dAe/4xXXPntx+YJ
au5X3Rkc+oUPRrZ6fHp8+a/0URMneOHzPmcZUSJcongWoVeYGlPi36nwDGaE1UlK/ohYxFo8
VrIlE3cTGBrGPxi+ZMLdpp6hOkut6iT/+/xA6NcXn750Annkt3Y7+pnDIgymdhG7Qo7PaHdc
wmEZCeJoGA/pGWM4Fx//2OAN3cVpuOdYXPX6Bp3dUNwRsdB7PFup+uI6iUmkOY2F9fFYKGf7
QnzR2B/GI8i2+2+7/fPmBXjP8+7l8X3HmrTnzE1QvTzsd48PToT7JMhTw0u4cGYni8DEgn+c
4hhc0oS/sm/fS8ykeo8XT5ZxC9EYKCS7EPw5zARJvRDNjyITixENUBcE/060P3QwDB+Bp1gS
6miVFioygSp1HRY1BYft6JKgCBi06oRGg+18Ubtm3E1RvVJlyUUGAvjl8JNLai/FlALK59WO
LVah/Srn008AypVjcd4UHGsegtrqeh26Eo3Mv3qBE30Pf4vI0EDs+cqfdxwncm1gWgESOjkk
DsWALEixBxQyrcf4QuNo3DIc+00ILGglg+BcvpBgXpnLHyYmGvk0vBh8eZxBdvVQwuiTkS2r
PZRq6jRjqwMJuka4E68vxuB6cMVd9+HHDha1Tvx8nfUf7A/wvpNq0C8wtoBiIDpVKwtgJ+a2
SktO+YMvHGHhUrstc4pCDMvpTpMvaR3Q1wUuEDUjefmb+x+uWi0siKqHmMEfeRr/FSwCYjAD
/mKK9Mt0emZpv6XENDLdFNJ3gNQdRBWEFt9ekdLir1CVfyUl3wLAnNrjAr5wShZ9FPzdvmuh
s0aGWukvl1MOblKM2AUH99+/fbx/u/6tu45HrKoMr7njoxxseyqS2AcB82V74GRv24+H3eQb
N+yBtw0V3LiR96gMAxOUUa8Qh4yvYgZ2QZdaCOjPTRTkmqP7G50njo/Puuj+LOPMpT4qOMHp
LY7MuebVTJeRx7ILOJ7DoPZzjRkoulRPfyQmg2FiaevbZMZOj9NcJTMtMzYVjMBCGaaJm0jQ
ufwhgCjni8SFR/rqjXRHBn0NRzi3n6tYABW3lSrmAnAxcsjEJgHyYFcqjQc7aJ7JNd0mq6tR
6FSG5k1bvFyLrxaCmee6WEifVRIFtpGbXCJsgaHLwPD34qL3+7L/2z0xqezK4Two/SwF0dyi
17xiEIEUfdoGrw0SdkQNEnIIEHiDxB1Q4HQ3gPEM+hvgoPoFHNZVd79SEYkAcJilFa+7JCR8
3jyFE0Z6hWtyEs8eDslXELV5CWFG8XYzjHvZGTv2s//TDqgzjTDkg1LFWeS+bUhRJXnWdTWk
3/Ws6BAPFIDMi2X1Te59cjNkdb8KTIFBuGFQJCPjA52POl9hszcfiY+2vs7mPO37pkvc+Au1
XmU3yD0VopH48tgdS309nKVWN3DHR+MY58WSgFXmq4izRCcoHTi96uigGtTTO7i6IBp/rxIq
uxjUYqPRBVWc1aJ9rkVku95ZtUDJB5DIwb5kAieKuhs1KlqZZiDvIKyVluqrS96N3UH6/EtI
n/kXbgfpWngk7iHxOoke0i819wsdlwIM9JAEluoi/UrHhcfHHhKv8e4h/coUTIXszC4Sm3K2
iwJitcOtHdivrOoXwePGRbrirSnc3grpGxAJriDX15++1LxDqFPNuWSx0MeSV14VPptwrduT
8/60tQB5OloMmVBajNMTIZNIiyHTR4shb6IWQ161wzScHsz56dGcy8O5Sc11zV88DmBe941g
zIoLgqPwbN9i+DoqBbXqESUpdSU4Kx+Q8lSV5lRj69xEUi6VFmmmxHQrB5RcCzYyLYbx0WBB
yFHQ4iSVEeSo7vSdGlRZ5Te9p60OBl6/D65B2/uP/eP7z6E5K566x6MOfx0jdB8FfWvnimnt
ASM3yUy4WjVV8JcrqzrSgYwCgDqYY5gs6xQiSFmNthLfYgt6QShz4wt+XoyidABkRQBKZkJx
yRMdkL4KY6SR/OWrnoJggMY3h0FYfMJBc0cbAo1pudWfHMep/E7IoSL++7efm+fN70+7zcPr
48vvb5tvW/j88eF3zED2Hdf5t4PshVN+iJHu73++vu8m92iKuNtPfmyfXrf7Iy1YZAwf7MQx
cYovhuVadYT3TuEQ1YtufMybmA/wD5DhR40UOywcoubJbFAzlLGIB5Fu0HWxJzdZxgwft4sr
2DZtCFGgG3DAP340UO0H3L5uoMAb4DjNB31pyrneINWdrPBw3UGbnGJQ/Sw8v7iOq2gwZUkV
8YXD6cIL/m2lK830kf5w1iXtVFflXFPW0/6XfRsi+xT28f5j+/L+eL953z5M9Ms9Uj+GHf7P
4/uPiXp7290/EijYvG8Gu8DvhiRqJ4DKBt2eK/jv4ixLo/X5pRCE5bAvZqaQAtv1cISbTgdJ
cupuVzXNq2IqxP3r4kBjXLLxBqXQt2YxmAsNYzYJAewbPhlMPO8eurEs2xnyuEXzQ851oQWW
QybhlwXTDY+pOsr55DANOB1rObO9dQtXZcE0A+fVMheUR+06oYdLWQ3f2+ebtx/SdMHhPujB
PFY+s2dW0Nux9he9VOz2+eDx+/btfdhu7l9ecI0QYKwVQCjPzwI3OH9v7xAfH84ht2t6JBpc
DWYjDj4xdcUGiFJH+FeuLo8DoPfhOQHFXSPiYzHsMq748mKIXczVOVfIVQHFn84vmFEAgJfv
W7gQv7EFlyCjeqmggGr45Sw//zK6osvskxuswgoQj68/HAeMAzcqGLKB0lrw62wxksozrDqs
gef+FTNDXpQuRaOuliRVrEHiHz2DfVWUo+waEaZy9wLNcYWQ/o5VezNXd2rkoCtUVCgiL+ms
GePWOuCISueZFC70QFf8nfFwxo7OZblM+0vSRGh8ft1v395sbOT+/PWypLfs+y5lhnB9NUqx
0d1o9wE8H+WUd4Ure1iruc3Lw+55knw8/7PdWyu+NszzkJYLU/tZztoptgPOvZm1oewPmSAC
j7cwyYu7i+Sz5iYdjEG7Xw3GpNBofpWtmUlHuRHDGp5s/4BYNPLzLyHngstzHw/vE2OIc/68
V8U6xsCxcO3CuyVq7ocEut2/o70iiIJv5Kn19vj9ZfP+AXek+x/be8yw7dog48NUxwOzuREz
8+6ZROVNBrGwvYMxQcEP6MC50fy281jdGrNhju2qNJHLZtM8YE+6JD1awfmmNikFqHSsllw4
C+oVk78t5XSNs5U/t+80uQ67Ir4PYrPpul9C0fnUJWm/HhEVoNWyqp1LGYgevQouMTduFPaF
fhchMr721tfMpxYiMQtCUflSCZElLIYn6G8AKmibAcJlsofiz07UYONZMUyqhL862Jxy4xNz
B3WjwZTLcql0wIiBA5MeyE1xjKWB7pQf2l/dIYBptNQgOmuknY5BxKGsvomzY6Odci9mi8Oi
U66KIvWNKs1CA3HmqvMMhm7hlFqvXzTcCFgexJ3A9wkcoFiCaKSz0b09gDAVBHld1tMrz5Q9
MFZIjgqIF6b5ILLzAQsR/HRO7LdGUThMBKwY+5LNsjzttIaAJE0ONZAxEjXdXRnqLXBQMV7s
LLJKrU7Ft53X5VmUOm4d+HuMypKoeUI89iAQ0mXltyj9c8+IKUUmgRtumXfi0oYpjPJoWH+o
CMtZOzfEv/7vdccUzJYQSzqMHzqRdgZcwJJaCulo7pDDj4265Zm4meCgjAJzOWSoDTAXgdEY
ENhu0FW/dWHVAUhnzM12/7J9mvzYtKcXlb7uH1/e/005sh6et2/fOQ8bG3SYoiWza9bA8R2W
1yc1AaSjdBbBWRYdtGyfRYzbCg3fDgHPYuAs+FY0qOGqo2dGT/+mKxTagO1rG4aBD1WAcunj
0/aP98fn5qB/o6m5t+V7bnbsa7Voc6oTUp7FFUgFAwPWlgIx2na9VHny98XZ1bVLYxmQRww7
OJZs5VVALSghLWyVwPmMWXdiL424HWEH0DVOm2vMf9UY3Dq7llALa8qBxmGx6rmxtR3vodDg
6jSJ1sPqKLlkY5+A4caFLJIU+AglLdfJyqnKmtS0FB9vn3cgVAXbfz6+f+9JbPT0SGmFCynQ
FKGky0SQWgmcpQZDWQkCq+1UZr3x+TBfFiX10DxGcIqzcx4pTj1FDxLN2OFki2AShxPcQsaq
L9EfoyqkXBgWS0ijaIHWTQU2guF4Yaej1Bba1IZwY2eoqwtmarpRhUos1tHtxPftEavg5Fs0
Gbwzn6l83vPRs6ovpJBJtLv/98er3fDzzcv3nktQWKJsW2VNvH3BqbcJxj+v4GgoVcHP+fKW
TbXXIa0ESB22T8rbajtw9Eyo9N9nLhCZdVqVx2IKcnKwwjmOC4vJqIh/nqKvLHVgzBjZBN/O
LzZ7o3XG5erB+T1uxsm/3l4fXyjP4u+T54/37X+38I/t+/2ff/75P8f7D1msU90zOm2HBz3I
P4uDZTrbNaoDxzjScZQAKxAqBSOuhnoYx8D+LjhZyXJpkWBLp8tMCf4uFpd6ToLYCJIqUzzR
igjm/URdOIV0HW+EFr6f1CoQOHqcy57Yx3HIEhARDu3G7orRWQCjgqMJFVM6aG4qI52/sRxy
bHhG6GfDhE/AizEOTm4IRgthm5oUrLnG1DtGuWesVRj5FX8KAQDPvFCeZcQ4uRSElEvRVRGq
bxlb+j5h3jZHcS4fwk2iWKIQOD3xGiPYLDRTVus8h+sOa/95lNVlG9EjUcKdK/HXvcCSh9Yy
OwF59w4HbCGsEiuIjENnucrmPE4rMIYtGTsV2JMm9tMK7hC5RuVLDwWdCpDWCRPEhaT7hkoY
fvOhraVzI6a6KcNtx0cKt7BNzNJx+lnQZRHwHecd+IPX5CbYwGB4naoaC1I0enbbd+prCobR
2MLBFu/Nu3Bt0DrOSrzx0QAEV738Fs7ecKwie0iNIMyXQD1jCI2Q3hpZWEzBIcsuS7OsPI79
vi4SNQg31F5WMIDIHM8u8quCG7vunWlUjmHpUNkQNB8IB8sBHehsFNEe5CMT0cazMumQobT3
CWjN082SdfQDzT7pl/ew3Tmi/VB7sLHnsZScrEumv44JIwWmmck8s0N9dFuUMe2CaxCzSPvT
DzXRNg57F4Qfqgb70Q+KEN0Egt8rBXghrXEhRaYmFBHqtYcsHcUjx4SHr4AynLxicZjjaHBg
wfEgw608Mr1iBQN3SHO9QjPvkTFbJUuTGVLGuwHEUnAEJgSrb5fhVr8zCofjTAgJRBhVJbhT
E3RFykgZzl14XIwcH1tK5FMj8ym9xxDUBPxjnSXAmxHqXMSyEGoHX1CiMMHIzc5gxk9/aDD6
uznFBpowSDaj6QjBkA/fSEdl1VBDcGSPJ1ojWmqLhUD0Nmyhjn04bkapWqEsLjwXwPfiriFl
QUIx+/ClJ68GbrdHXq8wt6FoxWg17bPA0ePib+aDg9q58ujuDTfM0tzRedP9mqDciUFfqcjM
klgn5fBWrkxASvFifeexx6XlbsCrw0jNiqEAolUeNW9qjv6jyZmLukGeJmz7/78o0Ngh9kCE
9vhwl3aQ7b7YjmYBAC8jBB0uJAEA

--oyUTqETQ0mS9luUI--

