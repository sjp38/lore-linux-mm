Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 048D88E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 22:59:58 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j15-v6so5816755pff.12
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 19:59:57 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f12-v6si25586772pgg.653.2018.09.20.19.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Sep 2018 19:59:55 -0700 (PDT)
Date: Fri, 21 Sep 2018 10:58:53 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 6/7] mm/gup: Combine parameters into struct
Message-ID: <201809211013.x92amJfa%fengguang.wu@intel.com>
References: <20180919210250.28858-7-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
Content-Disposition: inline
In-Reply-To: <20180919210250.28858-7-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Keith,

I love your patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.19-rc4 next-20180919]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Keith-Busch/mm-faster-get-user-pages/20180920-184931
config: arm-oxnas_v6_defconfig (attached as .config)
compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=arm 

All errors (new ones prefixed by >>):

   In file included from include/linux/mm.h:506:0,
                    from mm/gup.c:6:
   include/linux/huge_mm.h:344:53: warning: 'struct gup_context' declared inside parameter list will not be visible outside of this definition or declaration
    static inline struct page *follow_devmap_pmd(struct gup_context *ctx, pmd_t *pmd)
                                                        ^~~~~~~~~~~
   include/linux/huge_mm.h:349:53: warning: 'struct gup_context' declared inside parameter list will not be visible outside of this definition or declaration
    static inline struct page *follow_devmap_pud(struct gup_context *ctx, pud_t *pud)
                                                        ^~~~~~~~~~~
   mm/gup.c: In function 'follow_pmd_mask':
>> mm/gup.c:233:34: error: macro "follow_huge_pd" passed 5 arguments, but takes just 3
              ctx->flags, PGDIR_SHIFT);
                                     ^
>> mm/gup.c:231:10: error: 'follow_huge_pd' undeclared (first use in this function); did you mean 'follow_page_pte'?
      page = follow_huge_pd(ctx->vma, ctx->address,
             ^~~~~~~~~~~~~~
             follow_page_pte
   mm/gup.c:231:10: note: each undeclared identifier is reported only once for each function it appears in
>> mm/gup.c:257:28: error: passing argument 1 of 'follow_devmap_pmd' from incompatible pointer type [-Werror=incompatible-pointer-types]
      page = follow_devmap_pmd(ctx, pmd);
                               ^~~
   In file included from include/linux/mm.h:506:0,
                    from mm/gup.c:6:
   include/linux/huge_mm.h:344:28: note: expected 'struct gup_context *' but argument is of type 'struct follow_page_context *'
    static inline struct page *follow_devmap_pmd(struct gup_context *ctx, pmd_t *pmd)
                               ^~~~~~~~~~~~~~~~~
   mm/gup.c: In function 'follow_pud_mask':
   mm/gup.c:333:32: error: macro "follow_huge_pd" passed 5 arguments, but takes just 3
              ctx->flags, PUD_SHIFT);
                                   ^
   mm/gup.c:331:10: error: 'follow_huge_pd' undeclared (first use in this function); did you mean 'follow_page_pte'?
      page = follow_huge_pd(ctx->vma, ctx->address,
             ^~~~~~~~~~~~~~
             follow_page_pte
>> mm/gup.c:340:28: error: passing argument 1 of 'follow_devmap_pud' from incompatible pointer type [-Werror=incompatible-pointer-types]
      page = follow_devmap_pud(ctx, pud);
                               ^~~
   In file included from include/linux/mm.h:506:0,
                    from mm/gup.c:6:
   include/linux/huge_mm.h:349:28: note: expected 'struct gup_context *' but argument is of type 'struct follow_page_context *'
    static inline struct page *follow_devmap_pud(struct gup_context *ctx, pud_t *pud)
                               ^~~~~~~~~~~~~~~~~
   mm/gup.c: In function 'follow_p4d_mask':
   mm/gup.c:366:32: error: macro "follow_huge_pd" passed 5 arguments, but takes just 3
              ctx->flags, P4D_SHIFT);
                                   ^
   mm/gup.c:364:10: error: 'follow_huge_pd' undeclared (first use in this function); did you mean 'follow_page_pte'?
      page = follow_huge_pd(ctx->vma, ctx->address,
             ^~~~~~~~~~~~~~
             follow_page_pte
   mm/gup.c: In function 'follow_page_mask':
   mm/gup.c:414:34: error: macro "follow_huge_pd" passed 5 arguments, but takes just 3
              ctx->flags, PGDIR_SHIFT);
                                     ^
   mm/gup.c:412:10: error: 'follow_huge_pd' undeclared (first use in this function); did you mean 'follow_page_pte'?
      page = follow_huge_pd(ctx->vma, ctx->address,
             ^~~~~~~~~~~~~~
             follow_page_pte
   cc1: some warnings being treated as errors

vim +/follow_huge_pd +233 mm/gup.c

   208	
   209	static struct page *follow_pmd_mask(struct follow_page_context *ctx, pud_t *pudp)
   210	{
   211		pmd_t *pmd, pmdval;
   212		spinlock_t *ptl;
   213		struct page *page;
   214		struct mm_struct *mm = ctx->vma->vm_mm;
   215	
   216		pmd = pmd_offset(pudp, ctx->address);
   217		/*
   218		 * The READ_ONCE() will stabilize the pmdval in a register or
   219		 * on the stack so that it will stop changing under the code.
   220		 */
   221		pmdval = READ_ONCE(*pmd);
   222		if (pmd_none(pmdval))
   223			return no_page_table(ctx);
   224		if (pmd_huge(pmdval) && ctx->vma->vm_flags & VM_HUGETLB) {
   225			page = follow_huge_pmd(mm, ctx->address, pmd, ctx->flags);
   226			if (page)
   227				return page;
   228			return no_page_table(ctx);
   229		}
   230		if (is_hugepd(__hugepd(pmd_val(pmdval)))) {
 > 231			page = follow_huge_pd(ctx->vma, ctx->address,
   232					      __hugepd(pmd_val(pmdval)),
 > 233					      ctx->flags, PGDIR_SHIFT);
   234			if (page)
   235				return page;
   236			return no_page_table(ctx);
   237		}
   238	retry:
   239		if (!pmd_present(pmdval)) {
   240			if (likely(!(ctx->flags & FOLL_MIGRATION)))
   241				return no_page_table(ctx);
   242			VM_BUG_ON(thp_migration_supported() &&
   243					  !is_pmd_migration_entry(pmdval));
   244			if (is_pmd_migration_entry(pmdval))
   245				pmd_migration_entry_wait(mm, pmd);
   246			pmdval = READ_ONCE(*pmd);
   247			/*
   248			 * MADV_DONTNEED may convert the pmd to null because
   249			 * mmap_sem is held in read mode
   250			 */
   251			if (pmd_none(pmdval))
   252				return no_page_table(ctx);
   253			goto retry;
   254		}
   255		if (pmd_devmap(pmdval)) {
   256			ptl = pmd_lock(mm, pmd);
 > 257			page = follow_devmap_pmd(ctx, pmd);
   258			spin_unlock(ptl);
   259			if (page)
   260				return page;
   261		}
   262		if (likely(!pmd_trans_huge(pmdval)))
   263			return follow_page_pte(ctx, pmd);
   264	
   265		if ((ctx->flags & FOLL_NUMA) && pmd_protnone(pmdval))
   266			return no_page_table(ctx);
   267	
   268	retry_locked:
   269		ptl = pmd_lock(mm, pmd);
   270		if (unlikely(pmd_none(*pmd))) {
   271			spin_unlock(ptl);
   272			return no_page_table(ctx);
   273		}
   274		if (unlikely(!pmd_present(*pmd))) {
   275			spin_unlock(ptl);
   276			if (likely(!(ctx->flags & FOLL_MIGRATION)))
   277				return no_page_table(ctx);
   278			pmd_migration_entry_wait(mm, pmd);
   279			goto retry_locked;
   280		}
   281		if (unlikely(!pmd_trans_huge(*pmd))) {
   282			spin_unlock(ptl);
   283			return follow_page_pte(ctx, pmd);
   284		}
   285		if (ctx->flags & FOLL_SPLIT) {
   286			int ret;
   287			page = pmd_page(*pmd);
   288			if (is_huge_zero_page(page)) {
   289				spin_unlock(ptl);
   290				ret = 0;
   291				split_huge_pmd(ctx->vma, pmd, ctx->address);
   292				if (pmd_trans_unstable(pmd))
   293					ret = -EBUSY;
   294			} else {
   295				get_page(page);
   296				spin_unlock(ptl);
   297				lock_page(page);
   298				ret = split_huge_page(page);
   299				unlock_page(page);
   300				put_page(page);
   301				if (pmd_none(*pmd))
   302					return no_page_table(ctx);
   303			}
   304	
   305			return ret ? ERR_PTR(ret) :
   306				follow_page_pte(ctx, pmd);
   307		}
   308		page = follow_trans_huge_pmd(ctx->vma, ctx->address, pmd, ctx->flags);
   309		spin_unlock(ptl);
   310		ctx->page_mask = HPAGE_PMD_NR - 1;
   311		return page;
   312	}
   313	
   314	static struct page *follow_pud_mask(struct follow_page_context *ctx, p4d_t *p4dp)
   315	{
   316		pud_t *pud;
   317		spinlock_t *ptl;
   318		struct page *page;
   319		struct mm_struct *mm = ctx->vma->vm_mm;
   320	
   321		pud = pud_offset(p4dp, ctx->address);
   322		if (pud_none(*pud))
   323			return no_page_table(ctx);
   324		if (pud_huge(*pud) && ctx->vma->vm_flags & VM_HUGETLB) {
   325			page = follow_huge_pud(mm, ctx->address, pud, ctx->flags);
   326			if (page)
   327				return page;
   328			return no_page_table(ctx);
   329		}
   330		if (is_hugepd(__hugepd(pud_val(*pud)))) {
   331			page = follow_huge_pd(ctx->vma, ctx->address,
   332					      __hugepd(pud_val(*pud)),
 > 333					      ctx->flags, PUD_SHIFT);
   334			if (page)
   335				return page;
   336			return no_page_table(ctx);
   337		}
   338		if (pud_devmap(*pud)) {
   339			ptl = pud_lock(mm, pud);
 > 340			page = follow_devmap_pud(ctx, pud);
   341			spin_unlock(ptl);
   342			if (page)
   343				return page;
   344		}
   345		if (unlikely(pud_bad(*pud)))
   346			return no_page_table(ctx);
   347	
   348		return follow_pmd_mask(ctx, pud);
   349	}
   350	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--ibTvN161/egqYuK8
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICOBapFsAAy5jb25maWcAjDzbcuM2su/5CtXkJamtSSzJlu1zyg8QCUpYkQQGACXZLyyN
rZl1xZa9spxk/n67AVICSJBOaqpidjdujUbf0NDPP/08IO+Hl+fN4fF+8/T0Y/B9u9vuN4ft
w+Db49P2/wcxH+RcD2jM9G9AnD7u3v/+fbN/Hpz/Nrz+7ezz/v58sNjud9unQfSy+/b4/R1a
P77sfvr5J/j3MwCfX6Gj/f8NoNHnJ2z++fvufbv5+vj5+/394Jd4+/Vxsxtc/jaC3obDX+1f
0DbiecJmZRSVTJWzKLr5UYPgo1xSqRjPby7PRmdnR9qU5LMj6ghm8ku54nJx6mFasDTWLKMl
XWsyTWmpuNSAN3OeGR48Dd62h/fX00xYznRJ82VJ5KxMWcb0zXiES6wG55lg0JOmSg8e3wa7
lwP2ULdOeUTSemqfPoXAJSk0b0yyVCTVDv2cLGm5oDKnaTm7Y+JE7mLSu4yEMeu7rha8C3F+
QvgDH5fujOquvIlf3/VhYQb96PMAV2OakCLV5ZwrnZOM3nz6Zfey2/565JdaEYdH6lYtmYha
APx/pFN3TYIrti6zLwUtaGDgSHKlyoxmXN6WRGsSzd3WhaIpmwbXQwo4S4EeDdOJjOaWAmdE
0rSWSZDhwdv717cfb4ft80kmZzSnkkVGxIXkU+qcEgel5nzVjSlTuqRpGE+ThEaa4dSSpMyI
WrhiImOgUcDkUlJF8/iEw7YxzwjLQ7ByzqjEtd66veUxHJ+KAGj9hgmXEY1LPZeUxCyfOXso
iFS0anFks7uImE6LWaICTHepMhAkVk1Dnro3WxLBOV0oXsAcypho0maWoQA+5lo12s6JKjWL
FuVUchJHROne1h6Z2Xv9+Lzdv4W233TLcwq76HSa83J+h/oo47nLEgAKGI3HLAqwwrZisHi3
jYUmRZp2NXF2kM3mKAglalbpsEFISjOhgT73Oq/hS54WuSbyNnhgKioXZ02LKH7Xm7c/Bgfg
z2Czexi8HTaHt8Hm/v7lfXd43H1vMAoalCSKOIxlBeg4xJJJ3UDj1gSng6JiTMeJNkg3VTEe
yYiCngBSHSTScKCUJjokmzgfpnhKNDP7aBYto2KgAoIAPCoB5y4KPsG8wY6HtI2yxG5zH4St
YWZpehIkB5NTOIuKzqJpyoygntizsH8ETSAatQR0Dkv0zfDSheNiM7J28aOT+LBcL8ASJrTZ
x7h5kFQ0h5mZ43SacTSTvBDKnSZo7qhj39JF1SCItig7Th+BYLHqw8u4w1hW+AS25I7KMIkA
+6J7u4/pkkW0jwI66RTLeg1UJv2DgF4NEqAtBr0Mwh9uP6fRQnDYVtQXmsvwTO1molfUvR9g
JxMFMwEtERHdsSeSpuQ2IJG418Ap49pJ13rhN8mgY6vzHQdMxg2/CwBTAIw8iO+AAcD1uwye
N74dLwvcWy5AxbA7imbPbAOXGckjT3s2yRT8ETrptWtT2yTQwrBAHlNHQxvno2DxcOL4nyI5
fVhFcvpu0BrbCUIp3QmqGdXoMZSVLxOeHDL56Ou42wqz7mmZWEPtGBnjsLVND+qO5neZZ8x1
tB1vgqYJaDzpdDwl4F2gBTyBkkLTdeMTTrzTi+AuvWKznKSJI2Fmni7AGH8XoOago5xtY47E
kHjJYFIVd5zlQpMpkZK5DswCSW4zT/3VsDLM3CParB1PD7qAbgcgHKHNcR1gaVzzJA70f/SL
TvOF3vKowXlw6zyfzugbAw30CT3ROKZxQ6jx8JRNv8wAYYrlMoMF8MhzSqLh2XnL2ahiXLHd
f3vZP29299sB/XO7A3eDgOMRocMBPtrJIPvDNlbQHD6wmmVmW5fGx/BEWqXF1HbkqAwIPokG
13HhHaKUTEOHDjrwyXiYjExhg+SM1mFWs29jpNABKCUcRp6FFbRHiDEDmOqQUJh1oR8A/rxm
xI/GJE9Y2nC1js4L2BljTDzPO/M+jLQptDxeSJKBy6orQYmc8wuiXapCCC7BIScCNgM0XO2I
eeIFHh5O2mkKseDCzKnu4YRDtwRMVRth6cG1TFIyU228XCmaletoPiMxWMR0xiXTc2eJCeg+
SmR6C9+lpzhqz2i+orjYQOxBIFSVYDthm8FMNqKXIxcKE1/6LIat0kAj5sAu9KHbnXtSKmY2
2WLiTXUzskdLGV92oH+8bk/nJ8uKxkSyjIDXlIO1heAYNi6/uerDk/XNcOIToI0SsItoTF3h
Mlg6VWQ4PAuH7IZAXI/X6258wrmeShbPwr6Mocmp7umBcTHsHQIIxqMP8OM+/Fqc9/Uf82XP
5BfqanJ90Y1fXZ+tr896OJiKCKbfM75Yh11ig5Qi6kaavesZWo2jUf/SyZLlEesm4CBew5ZZ
yN6fDo+vT9vB69PmgJYBUE/bey8DKgqwD/vt4Nvm+fHph0fQEs9yOWmKvQVfhsETi/Gniiex
eyEkQjUW9sstQSpY3iMHoJ0F7dkLogTt8MMtXl8Pu7HTKGxGLJJKMALd+ChXcID6tpnNWMRT
Ho6r7Dlf3+a8hz2Y5ZiSfNFHoXoEKVv38A6MGJ2BLu6b4ILeQsjUt0MZjRno854pQnTGe/iY
ZeFgyyKX4Hv06Djh76BNYbEBHqDfSfZ7DP8kGSTmNNgT0jhmo/5TOO5HnwfRCsw0YsP6C7Ek
G3cpX4s+70PDki59tDevdU5cL50Y2NXorHV2BYjnOqIdXrXVZawjKjfYL1GHH2aVKCXpktFV
DwW4KNGc9ew/6NJJry5VF2I56jOlEpwDRXrOGHA0EbOwMUALXoKKIT1HROmeA6h0Nu4RMVXk
657WmuSz8EWFRePx7UYXOROY++6huLroM2RLCMQlVT28W2VXlxc9PQD+qg9/17Ozd7f5l9bZ
FvuX++3b28u+4cKhK7+cuGk4BFz633peZOD1E4GOoY8aj/6ctCGLFqjRI5lKDbHTJAht0AoD
btJW0AZtBIeWtmgraJiWCd2Ac3Hb6kKn0zCs0SlGMESxuNGlGF60IZX/3NifZLs5vO+3b67n
kdkt8BVRBaShfBJiTb6crp3VqZWoYiQ/R4U5bMuNmCnc466EZjkFuY5ZpEOEDhmc/Ei7SQIb
UULoS3LUn7YT7uY/MBdRzmkqbBh9yvrHigdGiTNSbaBcJU7ShRcQh1tMEGgyGMHQ0qLT0frM
2SkXdmLEEVqKLGxkRToenpVUgpdAyourq/Hk+mO6y9Hl9TBs+3y6i/H1ZVg5+HST6/PhdYd0
pMOaIZikLz2Ptom9mbg4ZD0Er5jhT6j0VYIJ4ilZ3pZGWuvNMgkViGBnOZiu6mrOk+RqxufD
4fWoS+2dqMZn15fjjnVVNJPz8eXwumOYy9HZ5VV4Q1yqi/PxqMsG+VSXH1LBfDpEwKWCzj5e
/uX11fCqyzl3+hqffTx76Gk8uiivLkbn/4B4NPwH07saXUyGHy7VjPjhIgzVuGXMpu940fr6
+rI/uL6p8ENDq1cBRncPry+PuyZtSfPYZKTCJymKQGd1pRjbStroEJW5dQyNj5LnZSH8s2LM
CBcQ7MxuvcSduVTJwkGIRaqsp0AhAyLvnvEItw4QJrb7WutV7F3ERSLsr04ZVtloHbQEy0wJ
QJZj/xr3CMWbkWCvNckofG9Vo4ehRKMgM1ryJFFU35z9HZ3Z/2psLs29nJN1mnMt0mJWpQc9
IRTKFygvgJLlTDB+ql/CC3i2prEHGZ55hgMgow6/EVEdDh+gxt2tuhxRO/pZaJPvboYnjlhh
mku8fA+lDVnMlg6ckilzl8Thu0psd8sTmvwkL5dgATyxwigdLEmXE7Gq60wEcTO6q/B1gfWb
Sa5tWpOk5byYUfDR/FVlPC5SCobSbWvqVszV9h3E7Bx8FelcbRvDlWGeX0vi1VTh5SyWDqyY
npvbahG6wFQ0Qg55qXIiSWcGqEb+owqGtV8BYfXjC3y9vGL+ytFQeJfBndtCULCzxr1HfT9r
pgA6RMsiCu3r3ZRzDaYcFAU6mGdt+FSpE9joHSFA30LXsW7sCM4DoZUY9SLLKItTltMyMYPA
aCknsX+j2dcMZguzCAmcJXDukBd0TaMGt8xNgucKSqLmZVz4qZi6SaF5eYcXc3HsuLo0YcDZ
YupBHGfJ3Hoes5Li5a/tfpBtdpvv2+etMWJHXLLf/vd9u7v/MXi73zzZWhrPXU8kbYeC2JI9
PDWCQBY3QzuE1Pl4iAwkWzZc8yPRjC9LXGTQpnhUcIqcK4NYWwwW15hLCzM/2L/jHAfx/vFP
786usprVdE2D5Ollg5VEA2PlB9vn9yevvJUcBk/bzRscid32hB08vwPo67bK9W4fTmMsE8dM
w8efY3fZoCDaR85u0/Nxm9rHTxVKeNV3FaAuIvHMf4VSCyZMxBJW8WxKZW4uvEKGEM5vSqmz
khpSeSYnfZMZUTW4sELKQLEuqCmvC47U6K275MS7pQtPOkq969HVl1LwFYRvNElYxFALVxed
HbImsoZNqJkpuFKsFa0YS9PcmipDfGSv29aK3OP++a/N3pXP44wTJrMVkRQNQkZCigGOuG8I
AWCrLIJMS1ZllMzaBC2XL4siTzvNOJ/B8aon1BJa0DuDX+jfh+3u7fErHLbjqhhelH/b3G9/
Hai2n40KbElkaC6Iosq9Y0SIsSbK6uwkbiAlGjewcyuJJsK9Q0csrKulK2ugUfBt/Y8UEREK
zbzFBrmKZM0y8CMSK2W1LRlelBnTbNaSWJsy337fbwbfar49GGnw8+UgYvJW6HA6Es18Af7F
Xbj7ush9s7//z+MBtBTEHJ8ftq/b3UNQx1hz5NdnGDvWgBmR4fa+3ksFLez9cXCu/wYrB2p+
SkPFKK2LZzPE6cwWufGisFLMuEyNs4a+CZbSg5sDroNXDm7r3IPdLyTVQQQEFkG4V1F0ck7N
xf6c80UDaZJMHMRzVvDC6etYxwgMMQbMFjy3CQwSq4zAB9R+7FfV1oDnqVlyW5ewtQlQDm0F
e3DmZuDKUStXc6ZpVevpkkoKrgtBe2LkuXJaiWgyoyrlcUFWG7sQ8L+nMKitDGwWWqBjjqOF
4CbDZ2eADlNoOScRC/n1+AbAlpHXTzQCXVTONii9VLsFVl1wG7fjrEBiNPWzklFk98BD1xXS
dccdbRuNYIu4WxBvuQvCBS6pEcAFa6E7Kp4bVIFa5wYFxDwVcwSNGBxJJwFqwiFlDiBW1ckW
65EBBmOqh9hdU4206zqaSmANsXrzhARaHStFohQYXE6BJWC1Yqc7jk9t2Kwy1+MWwt6aNwbB
8ksO2qd+oyJX648pnGKq1oHUEhPgod56UM3mVRgaah5CHZubKh4IK2KvdJUmZufrAkhrOyK+
/Px187Z9GPxhk1av+5dvj80wAcmqGXflOnBcQ1YZjJK4ZZOYPcHHIlxp8D4+ff/Xv/x3UPgQ
zNJ4wYMDDowLcp9hvaarwU2Zo8JivFNkWYmvl6uy7LMhPdr/QPcVTZEjvrOxRQdtIdBVOihs
K6t+lIyOz8Y6botrShZ2mCs0qq7OG0UQmwwmC0c4LhdYEdq5YmUfEaRg6lxrNPUr8dNpTBIX
uyhVpMBTo18K6hqXujJ7qrwMnwPuel91qunGu1imw49KaipMyoS20bwCqCJ7YxhkcxqraShM
sP3inUSimi2QiVyQtOWLic3+8GgCR7xBdatIsRLSRAkkXmL9tydRBDyv/EQTjorY+gMKrpKP
+shA/31Eo4lkH9BkJApT1HgVc3Wi8NinYrwXXLR8xFPnLIelqmLaPwd8TyOZKtdXkw9mW0B/
JtbqHzeNsw86UrOPGAPWQH64T6r4aK8XEBF07JMfMbX5i+8gJ1e9bZ3TcGxvnybygbr/z/bh
/cnLpjBu8785544+qKExmGyTFWthoqRR821feNYNQjFvRdLREifQ06oa9+bT/bf/Hs1L9qVn
pg5ycTv1NUONmCahGnWWGxYqAVYNTQD4q/5DR4s3jrfF9+GCbVeg8mhXYxfpt/ZrfYkGdywq
IbZ3Vm0eOZipgz7iq9x1dW19cgfSjNaBO2WobNrg7+39+2GDGQN8fz4wxfYHR6qmLE8yjV6j
px6O0DKJBQsV1APOD1Txy0QLR0nA5nOKUb3rGtiuVSRtNUdzzCQl4Ti/wmdMhaaDo1ehii0k
3T6/7H84ydh2BI4jeZXdCCjxIY+5M89akS0+rvDFIOcmse31Ur1hdl8a1krBXIUJbfbP3G2d
n6afiaZLDFZCkqZiWajQHUzNceOlg+YuTRr7/Ox64qSAUwoWDysFwpkriHk0hvNBVeVVAcBn
T97wiA1mwBALRoCom8tTkzvBedga3E2LsFd3pzqfetQRvSnfBwUiaeZfBdlQHy8f62AunEql
0mQcm89JT35xIcopzaN5RuQiMJGcHp8c59vDXy/7PzDz3ZJD2PgF9Y6ChYChJKFrUzSkLjV+
t2hPHmca2oZ14r7nwC/zCOLm2bmtQiAmAsJ3WYhFl1AmpONdpCEBBwKzKiwKu42Gxgp6Xyew
BUxpFnUtBfMNeG3nTB+Yj5W9QaPhc5sJe3WCT8SDcwCC2l0spSlQCvUqSpG7htl8l/E8agNR
Z7ShkkhPTHEFTHRUjlrkDFUuzYpQoaylKHWR57TxFDAHfcMXrCN5aBsuO0o+EZvwcClVhTsN
Gx4AN6Ak824cVeFFMzs13OqOfT0t1wVaKUPFDgc+V/5ToCZFfwdTSptt8eg1QDoSNdiffBGL
7qNqKCRZfUCBWNh1zFKFDxWODn/OjlIbYNaRJiqmbpKptiQ1Hty496+P95/83rP4QgWfpIPc
TFzBXk6qE4OFhIl/6mocrCoJ1Q0aCvsiF89+GZPYZ/MEhAiOvAcB0XG1wBGIdSYdGQZLc9Qg
7ugZE5PmCEYWKilpoMLQD6Vv8oH4Tdry11jgCW84Wj1jbl1U+MxvnHAXpZhu7RXAyokMMhDR
OYR1kfGe9K2gDRloMcYwt76vNo/YVHvAYoopkA4dYnowq+3GKzqblOnKjv4BGRjx8NUtMBh/
7Aiz0t12Hrw6gT+XpBRLbhtK3LQW81uT+QVTlokujwOIbc477ACLHiSo3DiKOtQm/ryCDuNk
x68qwM50PKvR4fKydNQxQvsNn+tTG4WmSNPuASh8CZeSvLw6Gw2/BNExjaB1eH5p1FE1qUka
ftmzHoUrfFMiwqkyMeddw09SvhKk4zRSSnFNF+GnNsiP7p/HiKOOtB1sFDF5rnCWStB8qVZM
R2E7vFT4Azodji/MCMLfRbedykSH6ce15Co85FyFRdus38w0puHFIEU6xl9TQkvTR5VHKqT0
pHAiVJmYH5hxtfDa/7GT6uc6zLmXLHxd7NBYvRDSnMbg44+0qNvS/4WD6RfPZ8OfB/h38Geu
jM+V4o9OmV9Q8+ONwWH7dmjcIphZL3TXz/GY0yc52Hies653c3OSSRJ3rbxDzKcdjygTYEHn
Y9SkXEShiDdh01JW9wkVaMUkTe199WkuyQxPVvuh6RGx224f3gaHFywv2u4wU/KAWZIBmAND
4DyhriAYjuBFy9xUIeKvhNycnUZcMYCGVW2yYB03C8j0647fxyGs4zdjqJiXXUn7PAnzUygw
Px2PRoxznYRxISNaKyClm484QPRLfHP3P8aurLltXFn/FdU83EoecsaWN/lWzQMJkhJibiFI
LXlhaWwlUR3bcknyOTP31180wAUAu+l5yCJ8DRAEsTR6FYNtPVzCxoHJqr2NUmw2FGbFyONx
tqSNoMNmcbRzP9j9Z/9omvv09hn7x6Z4kg1MLnV4CO3W0r+KVQx2tgvD7lB2tkzySJjssy6R
q6cyVe5yyqSBF1vaaMkRq7Y7IyQVoPAP12zp+bB9UoYq7XCsekOapihcS86yawc62A9eS10b
XjvISIIwZaU0OIYkzThXQQOj7QqJg1cRhMuC4Nc0ARjxNM3URZhQ7vGKzFMBTBpiZSIyIutR
mveqzJyYfUU4t8R4+nedJGbwF2U6oiRczfT5sX1/Pk8eD6/n/c/3w/tp8qKFifJrbCen/f/t
/tcw45GVYQuoE38DhpG31wNEhHGLOkK0DgZRk5wKHhHrwG6KcNi2iTxMJKCEb62FdK/EbwdR
m6n0Lg6dA8eTWlGW5ZxfsESUfj3nwpcV0XgnHLYasBP0K9tPrPG5rPVv/G0yud0w6vyZpwLV
nJa2hrgM1FQi9L4SlTNdmUGDDoZo0NLTCLd5LxKjlbOIqFfcDes5usu37fFkbGDVCYyLD6AW
0kFyyuP29dQYyMbbvy1lETzDjx/kgjTdpFWhFmD3G0RJHEkUwEmkiAKyOSGigHCRSchKagSz
nP5+rrzaAjvFGrjnKNZwMNiFl/xeZMnv0fP29Gvy+Gv/1tgFWnNdzYIIF4cB9jWU9w5qhwIC
2HMgxIFkDoJyUV/an8RBp6PotY3KbtX8EimbujNOviq9DAgXdzVTfSE3i8HIJdu3N5BmN8Ol
WCY1fttHcI4dDF8Ge8Ea3gZuv/QXBW90p6s6qM3u+ccX2JK3+1fJoUnSZleiPpiIx944X4yh
8s8YrNbQFLrg9jLYn/79JXv9wmAkBnyI1UiQsTkeeUHN+jRMPdT7AVCA6tA2IDbLwbx4pCpZ
zScugx1REIJtaB3gnHxHBu5WHzTExUOWknERejo5SvituCOBv+RRM04Ex5U7oEOqNpjR2LC3
oSfU94zzICgm/6P/nU4gUkfDKxCzUlegOqGbqdMl/TYi53WaYRwcoJXP7b1AFtSrWJn0iUUm
uUulE3QI/NBvbo/TC/tpgEZy60xGtlmgmcdV6NMbpHoILBrs+lAa0ufMEhHLw7OSd1AiALhE
QWELIkKzgUbth0IPmf/VKgA1qWXhLMssNb78nZoCf/k7CUzmMYuUAXqxhEMmTJzuw7UFj5Sp
jSrNaGlwXjWy4f66pouQ+o29FWbLlVZxDD/oWmBVZtmU9aVKe6wsFCV/OGham8fHjgHIgCwo
fHyldV30KRsxQOXeO+wcOLnpfvUOoSam7uG3NzdXpso7ADeG/KFkwZIIoCSv8vCR6rDEt77u
Ef5wt5frNMScLqC8ti/g+szcnx4xXlretpINzDu0B2HK4kxUBTD2xZJTIWAFdWKxqTuFtGVI
mMOxj/hma6S+v2Lr20G1cvfX9jThr6fz8f1FxWs8/ZL3oqfJGbhRaGryLE/oyZN81/0b/Nds
ugR3ukGb3vN5d9xOVISa3j/j8N9XuPpOXhTLO/kEDnT7o+R9+ZR9bpli8H55niScyU34uHtW
iRb6V3JI4CoTtG4fmqtgPEKKl3J+D0v7hhaH05kE2fb4hD2GpD+8dQFFxFm+gWm08ollIvns
yjKgf8HAfyVki2wwtmAN2nJK/cC0cwZMRZPMYggKjwfgTVMQ04xRsbhKXGKf4Auv9Io5iEad
UMXtCgpLHXDZvL1w42xLm7rW/pelAaVZUUsMX17flFMPIddQytyQ4gU9BvoIXH6+phBZSxDh
3uTT5P9ERgjoygpvUZbXSzUiKokCUXtJbXFpnCD+TEru2C/qJ3sGSkb3fNz/+Q7rTfx3f378
NfEMxyeDvB3mcgGG66X9CZdhGmRF7cUeA0s6O+eDB8oury4FMUO62on33bSbMiH5cdOSezhY
MLy8KrLCDnuiSuSpNZuhbvpGZZ1sILMYAf8aZ2F9loDoBWemxUbeWBPi9DceyDzJlNuBrOUM
w+QxVqUlrxL07RkvCltcw8Ts/q8PXpuBb1RqDdo8BBPi7sPjyzK5vyCCIgROneEzw+9wfzAf
qUvqNId4paknewDyVXeIhy1FXuEFnqW3jSTPy6gQmFE5H6LDZiFuYcyZkzSCr28WwbSeU/pm
qFVHIQ3nF9cku7IgnBxkOehUcU0CgB8P0qLyViFH5wyfTW/WaxxKS1ORZiCJJ5lmO0h5skwc
pRJSjbPCtmd6ELPZzWWd4Ck17JqZCBP8HVKvpLEQPMKyJMRRvNLs6t4OR7ieze7ub/FDqFyg
poxGc3BMQeYIs0mITViTM6VIPvymTeBAtP8QuNBUMhiQ8BJR2Rk/xHruh+60RGqGptuiCYAf
gby0FfgYi0RY0g6RsPtLInokQCQmBiDWFwZSwzV+WMnbMEwkU7eTgCeGfPdBGRYdOVgBEqxY
/S0TxIhpmkYub2gqVLET/NLs2ibNcnlw2I9j9Tp2d5th3SW3dm/5sy4WVNxaQJcQZMBxBxo2
u+LfHXNLXVKvbqjdtSO4QjdY2CKadBwGcwiFjppBlzHwt+LUGtE0vPQ9gnFsG66Taj0i1zKp
QLtUhCPNfbDDKxo5URmwvJgsKl9sYm742YtVvrAOrxgSOxV8PgfN2cL6QvoiyvkEymkJqpcE
bs0ea5gqmgASR5BgObu4omH5ve7W61F8djeGN/wXScC45JjovjeMDIlDXOux5oN8djWbTkfx
ks0uL8dbuJ6N47d3Lt6yJhDYqnbmA2d5XAmyRXVG1+uVtyFJYgGc3OXF5SWjadYliTWH/Yf4
5cWcplEn/yicKf7vY4qSHv6OSyApdJwRj+7JN6x6eyiHcK15cL9QcxCTTbZRhEkCONlosAwv
L9a4zA7uWHK75Yx++FJezYQISXwNmSTk7ii3lWkBf6NUeU4kHIptJYDahkDC8uW0f9pNKuG3
ggtFtds9NRY6gLR2Tt7T9u28Ow5FHKvYS+3TRxsJ1asA09kCeXcPDBL5pQz7IhMr7atquRh6
xKDVEpMbNiHj4oigjAuW4ZDDYbtQIe8g1v0jEyXq5GNW7HlzDGyioeNo4TX2OximJz8BCo4D
phuzWV4S9N83gckfmZA6ucI07Yw9QmXxNVntwWDi09BL5zNYhp12u8n5V0uFnJYrQtSjxViU
ckpZ7iG2Tf2+LIKhXIa/vr2fSYkeT/PKsi6XP4EdsK2rVSmknwyTmPJU10RglEjZU2oKnS3y
gdIQaaLEA4dcl6gza3iGZIP7NpCRNbRN/Qw85kf78TXbOAQWHC4dbUlb7CxaY4wH+lur5kO4
8TPPTHLWlshV/uBbMtUOiR8eCM1IR0LymBaF+jCERXBHqEd9nCYNVyXl/tzSgK0wCFvxidKR
NbfCD4jKbOWtPPwg6amq9MOBonMTdCTr8sNWfNS61Jh1xh0Dfta5mCJFkORDYOX+JsCK42zO
5b95joHyGuflcCJjINvktsqyh5Q3Yxvrp2doOjyMYfejdPz940M4UThxOemfllVs8YDaJPdE
EaRjdgW7GhbybutRgTaAwMvzOFRPGSGS3+/m/o4wEVAUSyHvEx6hnFAU9LVOd7T9HDVwHKM7
EPgp4b4EmkR5uhBOhpoAXldIPpdKlqonpuMDbYh8+PVAp6IZqu3xSceL+z2bwJlhhjuEJLbG
dRJ+wt+2p5IulhdPvQJ6/k2VFx6eA0OjjShf1hwhkmjixAp0mynYB214uT9OoDdPgqRSNCg0
95IQ1aOyX9vj9hF4z16z27LWpREIbGmmLtBKHu0Ppr3EhUnZEmBlbqTIxcqg7ln20gDAdd7V
jLVvnPL1vbxrlhujA3E499iGLGzU8NObW3tw5Y0olQ9Uls4Fvu2m9VzgzFCT4A03DpdHt2Nb
IUsenHDEjZnYcb99Hqqfmv61Gd3sWS2B2fTmAi00I+3q4FPCnfwtZQTsNtZ9k2jwZU0wLepK
WYteY2gbfbElQTuho+YSnIFJqLNK1Uto7YM+RyKm3jmgV33XIyKNoflm5XQ2w4SyDRFY0faS
VG17cXj9AnUltfri6n6IGDM4H14H35TXc7gGjfULhiXmJZoAVlPY0S+MQmw9NrBgLCXu4Q2F
PM9uybxImqTZTL+W3tz9eATpR2TNBT4XH1LKHXgMljOljvOPGmEgXIcogePZw9oxA1eA0aeq
AFYV4cco9yudoxaFF0sGfpP4WZsnXfp6ZBrI/VXH2TP9jbtCHbefZwkx/Yur+1uca1EO4LSn
RcnkHyLEv/yO8cYZCX2hmTJscUAxOq45LsIRckTwYUS96nLba07+HApJtM17LiaPz3ttToQk
i5AVWaxikz4M0iFgVHFAMUgGkcv1dT35qSK5ng/Hk2tKlJe57Ofh8d/Dizf4/17ezGZdqnRT
vKAF9hO45ZL+wIacYfv0pDwA5Lamnnb6l/EcnrKyMGP68TSp1tZv+F9f0Hp39IBxiqrsubpJ
fLw0BvoA7AM3aKuRGlST5/kczTfRBCuEuJqVvBImmi8zFGjw21JyNAXKHBXcsBqL1Zs+9r88
JVSeh0EVXnxzLQX0m5OMv+oNFcRZgb1uzgw39LJ9e9s9TVS7iJxI1by7XmsdEf1kvW3TeLCi
PJAVHJXwz8Ulpj0zO4+qJzVBMT40i3iFcxgKTfzZrbjDzzBNIJcIkX5e4zmbUWkn20/DCKmF
wvWBRuPfwyWy+JMo0J9u99ebXKvOx1uUrA7JYVnhCXJ0PHRviR9OGlUBrEdwiCIWY7qExSpx
bEugoJnbrm295pq2ZzkpsakpL/0iK8RYstGWJLq7nF3c4KYkJs1sGuHCoJZIT1ZCdtoS8XKG
p2xqCRJvfXk/TiKn093VLa5tNmmuiexQLU0qpwCYM0FAEpJpaUhZeXs7wx08TJq7OyKDZkuT
K4XoKI1YlEQuso4iEez6LsHnqE3kX30wmMvy0nGoHpCsZle307vF+BTRRCFBpYaZEA+tINtN
kGH3WSF8MwFA/1CBWcT54BCJkQMw3B4gN/GP91eVbHjM+ygKtKKnjuJwTaUP7akWMSNc44AG
tJE1YS8KeALOvYR0Cx4hOCPcjCS64LfX08s6TwhpH+x5+XgTD2GSx4RfDXSvvKUmFMB5Qm70
AIvk5oLIPOavby4uKPthVVedEZbcUZaWXCWmvVnXpWDeyLiXd/Ht7Ro/ZRXObq9mdx8Q3F8R
BEU4h8waxCZSsMGL9U2D9q2NLDmYo/Pj9u3X/hFlo3mylneaanlFNx4U+GQNIJdgXrNw6NTg
sXzyyXt/2h8m7NClxvwsf7z+2P98P9rpXSQbGe//PG4lr3Q8vJ/3r7vOpDg6bl92kz/ff/zY
HRvdi52rg4pzwh5i5UcjlxE5LrI3p8Ozckt4e9627llDNl67YmAX+KxKhx4gCx4M21i4mbMC
CMYiOboNhA0P0zllu8kDSopaLdDwIdC0w4iKt90jyEOgArI3QQ3vmlQCKJgVFb4iFZpT4SMU
KohruAIr0P+SsB/GD4RrO8BMHggFrjbSMBjajuBZNScyHCtYLSsa3tAhvQGXH26epQUX9NCE
kFWFsL8FOA6pk0LB351YhhY6DxOfEyJXhUfEugZQNkwrWRTBhn6rlbyqEM5g6sGbgg5CBgRg
jEW3zongXoB99Xzi2AO0XPF0QXCW+qVTuJtSqk8giZliv2mcYJM1lmZL/KKg4GzOR9dg4s05
U9qnEZJNFHtUKCWuYhuoWUm3oCydsgi/eyiKDAxIRiaeCuE2PntSIo4kYHKnDgm5HAf//RS4
wDgbmdl5WHrxhrjqKQIQMLKRBkAnWmSpE1vUpinImD4AC4+PvcaYWlzhcOFyo+LYFKQHUoOG
MUhCCf28oqlSsACk5wol14M1DMpIyQPSi00kXlF+zTajjyj5yIKQe4igrp0KX8jFSg9BuSgq
cFJ2YzxYRBWcrnUucFZWbWacJ9nIlrPmaUK/w/ewyEZHAOyS5IqjF6S+GdWLCud01Bka55hI
qpLXnmzBeJPgFdLlcjMRJ+ANa2QXdklDFsxiWhxNt7bUkWWYLxiU57/+Pu0fJd+hApFgnEea
5eqJaxZy3I4HUCUSWFLCfKCoYkI4rap7wZyQpUBUSpzbh4qtxfToY0klQ7UirgFEVuBEMgOu
pUA7TOGqtddqSuCXDiGHldXqEDBVEArzC2CJUzB0BD2wPArn4ZB9hSMM+VSqBc+T9/x7XGai
HwGaqunsA4KbGfKSCm5ktXaduLy6ucdXqMIfymB6ez8deRNlGvrn8/71358uP6u5Wcz9SXNY
v4NUD+ORJ5/6bebzYCxGxI0KT+I1ZfCvcDeKdtfl8rj/+dNSVCv6xnbf/eCtSb/SgRBYlkKg
h3IwsC3uRC3BSBah3M790KMb6e5cHzXlZGq2MAh3v8T9Ryw6W6ZvQW2w4j53xv5NJTs4Tc56
ZPuPnu7OP/bgaA6BveTNdPIJPsB5e/y5Ow+/eDfUYKHBnQA4OCnzEkoQY9FJtoaQtlhk2nYU
l32opHDc5zGVjYfLv1Pu4xFkQnkMtRkphLzsmRkbARocFEXJaq2L6SUUskjtP7i4AIRSSzdU
gXYcTjy/iowg+P0NG8K9Qc4q/J2rdcBFHhOWgxUhlldp2Zp8uMhQAAz6Bp3q1qoFxQmmJNg/
Hg+nw4/zZPH32+74ZTn5+b47nVHbg1Ky8QTnN8/iIOIE+84WRZaEnXqGiJYUxpJ3zdZjUWuY
CgE2SCLVpguEEIS5ZyfxSECFoFMJNpKTl5fD64QptaeS0YCJtPma0NBCBDj/CuC3rOBY9pb+
YUMN4mIFCU7cmDH6saor4vB+fEQczdXmaCXP1iVOZED5UFEwJxIgGIdoapHPLoxQW6p7ECW2
23v7z+Dx2M8w4xUuX68yVpMVhlKBk3wrdx+lIkbCiOj6YK42V3aDdZx7RLBrl1K+yPKOsOtW
tEiCjn6pqfy0STUY+GL3cjjvIFoFxjVAPMcSQocMZYTF28vpJ1onT0S73NC+KLEb+GwM2hTy
OZ/E36fz7mWSyfn5a//2eXKCk/1HF+WzY1G9l+fDT1ksDszlXv3jYfv0eHhxMKMHrA12OOhD
us5/j467HaT03k2+HY5ymiOP2P8rWWPl3963z/LJo4+2b88KXUNiwL+oSo0tz5LhKRpUyuel
m2y8g8N1SXE6Oq8NPqeIr5evhhZ6EOZGBYob+i50anpjIs5N/9emQMXdTYs/LrttXO7uXgnp
DiGGjB3BaYhB1Wuj85BtxWXtuwc21yOdZFiWlgUY3puZmj5ABjubLi75GFcZJcNFBN5X4v3P
k5ryllVBq82nXSbrhyz14B5DOyaCQUq+9urpLE3AnoewnzGpoD2SCiL9QTj0OgmS21vC1VdJ
2BgVXIwNV1y+O6oUVq9y65fH0v58OGInr0rlLK/DeYKvAo1jWdkAkbWsD+YN2Rjv9el42D9Z
z0yDIuNEkHZCfASRooZLZLGCwCuP4IaEchW4IER7cRK6BRVbCQWIcD5liB81gmeEMjrmCWZ6
FkHaMT1pjVM6UBGj61VWDLNMRwIOKTtlk9yXpjVxXknsqkYtdSRyXZvhmVUB2PRHED9Etuk8
A6hBIczXsle4qqKlEiGryGyYiihMVbg0SvytaCinwa9+YPUNfpPEEG7ab0NwG/sMl9dOiRHD
9pWG1jQkmQbyQ/jlyONSHo9UjaaDmv3LdR/E/JDAVNkpQdsyHWqwzlBJmUqKC7iVejkBm/US
0rY5uLFOiO/Z4WlW6twf7RR3C7guUNIAq2lPA+jAfKsyIrAWhLuOxDU1ohomx1stAhxrghY6
sN6Cto+/HK2sGKSU03DwBQLrQtw92AH6DaDfr0R2Lw8GqhdVEGE9CDLxe+SVv8sbud1uN5il
teJ1DlSzZOmSwO8u5WUWhJAZ7o/rqzsM5xlbgL9j+cdv+9NhNru5/3JpRls3SKsywoVjaTn4
LvpsO+3enw4qT+PgtYCttjqtCoCDKGOnUCW2a5I3WDaZAEoGKw6KEJvBkFjafIIyfzRuUXag
ex3lHlmZGlhDBDnjK4TalCX0SmuP0v9QSz+M+NIr4LW7xEHg+aTWqA6PZa3/rAApJz3nvWAE
i2hsMQqpyArUhjjSG5+GRmp9jYabaLtgfB4JJ0tyW9bnr1PZqUdq1/F340LclX535D8a8JQ/
CmJz4VZvp8OwY6ObakfVHrbW3Cm8hBgl8a3yxIIAlyOnm056TO2LychEyGnsW7q+HkVvabRA
HtquZ7BBNNNJqN+w/cRylXVpyK0tQJPITzyepbyju/6ndAv2jyhn19N/RPddNDHDXUKbzHjH
8UFoN+UB4YDgt6fdDwgj+tuA0PHbaspBgDEo1AFsDcmmWJLHHPV5W0cBYrNLRzitSOC3EJUx
hqjEOAVkgUfvmlTnYzNAVWwMr3FqGnB77Nby2LXe0sTurnA7QpuIsKe1iGY3+HXUIcIvtw7R
P3rcP+j4jLBP/v/Krqy3cRwJ/5Vgn3aBnZ62k8kmD/2gg7bV1hVKipO8CBm3kQTdOZA42Jl/
v1U8FIqqorPADLqb9Zkii0WySNbhgWhrSA/0mYaf0q9sHojJSDYGfYYFp3TgOw90fhh0fvyJ
ms4/M8Dnx5/g0/nJJ9p0xjigIwjUXBT4ntEF3Wpm8880G1C8EERNklGuWG5LZv4MswSeHRbB
y4xFHGYELy0WwQ+wRfDzySL4URvYcLgzs8O9YQzvEbKusrOeCStsyUwe3RzdGhLc/bnIMgaR
CExcfABStqKT9A3tAJIVKHOHPnYts5wLDGFBy4iNHTFApGDspSwiSzBWBeNDbjFll9HPsiP2
HepU28m19w7nIPAQN5jW7rbvrw/7v6nHy7W4ZlRRo7n2aSEadfnbyizh3GMDV0qWSO636kEP
DqapwGQ3eMGQVPW1SuqVRN45cAKjLwgwDt7iGh9gJJPfW2XlTlQ1mHqWTS1mD8QfrIiIhMOD
iv+RXk1nGxgeIl//ftk/H22fX3dHz69H97tfL25aNA3GLOZR7QSGGhXPp+UiSj9Ol07hFBrn
6ySrV0JO8ANl+iNME0gWTqGyXE5qhjISOOhTk6azLVnXNdF91H/n41OV/gaTf9WQU+bdWlNF
klLzyVB1ZOYpF0051Rrffob8IeaUUY+fKuUXUctyMZufFR0VJdggMHPGpF1YSDWqVn/ylaH2
ftGJThC/VX8wSrrp1BTiDV3XruDw7Fp+GYqfL0U/WLzv73dP+4etSpEgnrY4m9CP6b8P+/uj
6O3tefugSOnt/nb0um9anDDZJQxvw+RkFcF/8691lV/Pjr/Se+Yw+5ZZM2MMyzwMfUXvguZ/
0NqEZXMlu+b0hFa7XAx8LAhqxEVGRR8bpsQqysrsEoZLvzorG4bH5x9uvBjLrJga1YTxf7Hk
ltY0BjJzurPNC1aeS9otZZgJMb3hG/pV+OOwd24kERluhTnZLIsmHaIDGtsVFqgED68ONPTS
q9SkOrjbve2noyST43lCzu2EOVh8ANrZ15RL62om1Iqz7bdM/8RUKtKTwLKZ/kGwqMhAUlWW
ySCnZJEemKKIYI60H4gDsxMQx3PKi91OulU0m6zXUAjVEl0Dwh+z4MgAgj4UWHoRJLdLOTsP
fmBTey3Qkv3wcj+yYRoWMGobg9Ke8amwiLKLs+CUi2RCH20Gjaba8NZpRowjtEBj3AIGTNMG
JRQBp/wAp6IhBnIx2XknS8oquomC+2sT5U00D8qn3bTCyz7jtTDQZc1Zjw5CFRyKphZMSLlh
uw8OQbup/JG0dn0vr7u3N+2d6bNdXZ9O1EX9NuB/4ewkKPP5TbB/6vI4BMC74Enr5e3Tj+fH
o/L98c/dqzaqs46m09nQZH1SSzL+me2wjJfaCtRfTRRFbSfTjmtaRB4eHcikzu+Y004KtBiq
rwn5Vpma4bgyqZsFNkbt/xRYMiapPg6PQYEtdkNxBHPEYfTCqbjtXvdomQc6pk4W+vZw93Sr
cgVt73fbnzpJvaktzspImrhNC3v+I/yGB3iLqbSlG6xTmiDd0zg4cAAvEzgcLzDJmXmLJyC5
KBkqxu3t2sy94h5MsJJssF0xJGVChq/tSVFfJaulMi6QYjHmXoLmSi19mkhmpz44qD8kfdZ2
PVPXsXeUgQJMGL1gkiwaQJ4lIr4+I36qKdwMV5BIbiLGq0ojYuYeB6jMBXTC718JfTeYZ7HW
2Lif0cqMDuYV5tGNijFUekumKp0spO7T27g0FVT5CVl+dYPF/r/7q7PTSZmysKun2Cw6PZkU
RrKgytpVV8QTAgZ+ntYbJ99dKTGlDOc++tYvb1zLT4cQA2FOUvKbIiIJVzcMvmLKT6Yz2b06
s7KA8RKbKq8KN4CkW4qv2WcMCT7okNCmVAWH84vwJb0fLSBYnhajFGZQLSatx9TQeAknXPCl
GPqgEttXK7XVOHYdy1z3ztne6w50bfej6YW7cubV6PEf/x2aEGXuP/cnlUyZAwWXDxcNdTHI
NVE/zKxF6joyJhi1uJUjk67BdLdZ9urw7XAAFhzPvlD/muyU2nzWu9en3a+j+1u7U6nSl9eH
p/1PFdftx+Pu7c65GTb16tCDymvAYbcJy5pXyxz2rXy4zfsPi7joMtF+hAUtQG7xLWhSw8lH
l3Rie/39VHCOM+l1GaEjEB2YD5XEh1+73/YPj2afflO93eryV+oqXIefgvWQSuQlSnVFV3RN
ixEdEicXwELCgaLfRLL8Nvs6PxmPTd1HTdE314wvjARVRTs+MOFluxIDyGMFcZUzpgfI0GpT
MnfY2CnXAGolMPBOM/TC638jElRA0GCpwHBFRJ0+RPW9r8r8elrdopIJMEdE677WfnVEhSpq
AFobuPbvTuFw165H4dvXv2YUSkfVdJdKbAGah6k8E268u3T35/vdnZ4RY0aqOLQNZ/tqAg8C
UK1E/HjUVdZUJZvVc6gGJIBWhzREVilm+vWntoeq4u+Cuyhr8i62MCZgGSJwOWYfaAwjVdaF
iJAZSwk0EepP1qBOQpcDqEvKF2xYEA0mk20X5dNWGEKgeu0JAlOc0dvMsGg5xV0q6FqxTqpL
Z21M9KIdlVBsokLXo8MX4kMcWnmJlPUlHgrqUf68/fn+opew1e3Tnedts2hzFZgQampBEJjg
TJrYr7oSs9g29GhtLsgoZY5wlzDfYPJXtJnyiN5fRnkH03VMxD2l6tqP4gaWolRzYbS1YfFE
LsdkI1eiTPV6FuAvfnYtRO3NSX1Ew0vtYU04+ufby8OTCmD676PH9/3urx38Zbfffvny5V+O
xzMaa6u6l2oLHvzlPpglq8vBKJvW7rEO7GNoDQC9qmvFFRMmw0gP4XToS//BSjYbDYIlodpg
rNJQqzaNYDY1DVBd41dJDbLevBga/kBdyGN1ZWBUHfrb6qswA1rMO84umx8d5ZVBJVlqHrtD
qrY66BVszHiFBhKoT1qBxq/18sxuzvD/pZBx1YjpmpZnwYW/zg4hmtAGpMz3M8FkzDbhOCX0
ErPmjbUPfZmVdPROCgRcRhf8CCCCGyYHguswDATw264a85lLn4wPFooLIl6zL+oXRjWRE6XE
Q2qnDFAL8JKIOe9DK1dVW+d6o1P2m8qtjkRbrvdCSpXr6rvWp0iwsd4PYvCkXibXXjyr4Wu1
5pL0DluLrtRqXJi6lFG9ojFWBV/YUeCJ/SZrVxg8sPG/o8mFSs0AADxweRB0FlASgEiVJcav
JDE/1LU4Jv2qbhvY2koILiRxt1i4/YGzCHwe8aOzGA4jjnwDzU+mXJjgTcE0EsFiIqge++nN
Fg7iRd3iiVI1kHGMlhegAixCFem9MgBYbUCIQgBz/rGKuEYyLjomJYYeNia6vfp935SgY8HM
IeQ2hnUVWA5bqPJsKqtSeFurKo9KmE4qyYX+AbO/DXCQoyBQ6xMBRsT5Wt0WZ5VGEU3vlMu+
GTLHxnpcOuaFkus+hnm8KiJJb+OO5P4fSOgRLLM1vxQ7UqaO2zxSD6wArU5d4fgxL7xJoHs6
CZeDlzu4j3NOgTZbCLYCq/FjXOTrlHEkxV+o/RBUYiaRg4Kw1Nju+EovCGxecQs84+kqfSFy
KQyDHRJ3DpaulaPTE1JLGXdpJa7SruASZWKf9T2RtnVj5iTi1gBsGU9ZBdBvGzxdX1EF6bD5
MYF3FaLrGGdkRUUnvwWopzxC4uuTCicR4Bf3QKWoWUq/TGoBWwekT71BsbaJmgE1zb1FBocY
4M6Bqa3qWGSyAE000EHtYRdoKH+zZuRF2Uiy5qFaWIqKCaAsClZe9U1Er+41YNOWHe9p3ERF
nQv2WkKdxNfLdHTHi/+mb9LiJqId54frBXRq77NGnVo2YhRXTlu/Ggw9W9EBv8VZGAxSYtRP
Ku4K1tCVG5CD6UHAtyT0zwnUdbMlwXqU5DDg3/7xeLu9//0Hauy/wV9fn780g80qqCP2XWGA
K+Tv709b8+T+5d5xGa0xzmlpVaSMuQ1X6Rf9iFv/A5HMORFu6gAA

--ibTvN161/egqYuK8--
